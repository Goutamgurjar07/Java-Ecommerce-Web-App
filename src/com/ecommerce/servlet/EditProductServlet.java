package com.ecommerce.servlet;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Product;
import com.ecommerce.model.User;

@WebServlet("/EditProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class EditProductServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("failedMsg", "Unauthorized Access! Admin login required.");
                resp.sendRedirect("login.jsp");
                return;
            }

            // 1. Read Product ID
            String idStr = req.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                idStr = req.getParameter("pid");
            }

            if (idStr == null || idStr.trim().isEmpty()) {
                session.setAttribute("failedMsg", "Product ID is missing.");
                resp.sendRedirect("adminProducts.jsp");
                return;
            }

            int productId = Integer.parseInt(idStr.trim());
            ProductDAO dao = new ProductDAO();
            Product existingProduct = dao.getProductById(productId);

            if (existingProduct == null) {
                session.setAttribute("failedMsg", "Product not found in database.");
                resp.sendRedirect("adminProducts.jsp");
                return;
            }

            // 2. Read Text fields
            String name = req.getParameter("pname");
            if (name == null || name.trim().isEmpty()) name = req.getParameter("name");
            String priceStr = req.getParameter("price");
            String stockStr = req.getParameter("stock");
            String category = req.getParameter("category");
            String description = req.getParameter("description");

            double price = (priceStr != null && !priceStr.trim().isEmpty()) ? Double.parseDouble(priceStr.trim()) : existingProduct.getPrice();
            int stock = (stockStr != null && !stockStr.trim().isEmpty()) ? Integer.parseInt(stockStr.trim()) : existingProduct.getStock();

            // 3. Optional Image upload check
            String fileName = existingProduct.getImageName();
            Part filePart = null;
            try {
                filePart = req.getPart("pimg");
                if (filePart == null) filePart = req.getPart("image");
            } catch (Exception e) {
                filePart = null;
            }

            if (filePart != null && filePart.getSize() > 0) {
                String submittedFileName = filePart.getSubmittedFileName();
                if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
                    File temp = new File(submittedFileName);
                    fileName = System.currentTimeMillis() + "_" + temp.getName();

                    String uploadPath = req.getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();

                    filePart.write(uploadPath + File.separator + fileName);
                }
            }

            // 4. Update Product
            existingProduct.setProductId(productId);
            existingProduct.setName(name != null ? name.trim() : existingProduct.getName());
            existingProduct.setDescription(description != null ? description.trim() : existingProduct.getDescription());
            existingProduct.setPrice(price);
            existingProduct.setCategory(category != null ? category.trim() : existingProduct.getCategory());
            existingProduct.setStock(stock);
            existingProduct.setImageName(fileName);

            boolean isUpdated = dao.updateProduct(existingProduct);

            if (isUpdated) {
                session.setAttribute("succMsg", "✅ Product updated successfully!");
                resp.sendRedirect("adminProducts.jsp");
            } else {
                session.setAttribute("failedMsg", "Failed to update product.");
                resp.sendRedirect("editProduct.jsp?id=" + productId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
            resp.sendRedirect("adminProducts.jsp");
        }
    }
}