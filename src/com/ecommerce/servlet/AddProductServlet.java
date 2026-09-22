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

@WebServlet("/AddProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AddProductServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("failedMsg", "Unauthorized access! Admin login required.");
                resp.sendRedirect("login.jsp");
                return;
            }

            // 1. Text parameters fetch (Supports both 'pname' and 'name')
            String name = req.getParameter("pname");
            if (name == null || name.trim().isEmpty()) {
                name = req.getParameter("name");
            }

            String priceStr = req.getParameter("price");
            String stockStr = req.getParameter("stock");
            String category = req.getParameter("category");
            String description = req.getParameter("description");

            double price = 0.0;
            int stock = 0;

            if (priceStr != null && !priceStr.trim().isEmpty()) {
                price = Double.parseDouble(priceStr.trim());
            }
            if (stockStr != null && !stockStr.trim().isEmpty()) {
                stock = Integer.parseInt(stockStr.trim());
            }

            // 2. Safe Part Fetching (Checks 'pimg' first, then 'image')
            Part filePart = null;
            try {
                filePart = req.getPart("pimg");
                if (filePart == null) {
                    filePart = req.getPart("image");
                }
            } catch (Exception e) {
                filePart = null;
            }

            String fileName = "default.png";

            // 3. Safe File Name & Upload Handling (No NullPointerException)
            if (filePart != null && filePart.getSize() > 0) {
                String submittedFileName = filePart.getSubmittedFileName();
                if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
                    File temp = new File(submittedFileName);
                    fileName = System.currentTimeMillis() + "_" + temp.getName();

                    // Upload folder path inside webapp
                    String uploadPath = req.getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }

                    // Save file to server disk
                    filePart.write(uploadPath + File.separator + fileName);
                }
            }

            // 4. Set Product Details
            Product product = new Product();
            product.setName(name != null ? name.trim() : "Product");
            product.setDescription(description != null ? description.trim() : "");
            product.setPrice(price);
            product.setCategory(category != null ? category.trim() : "General");
            product.setStock(stock);
            product.setImageName(fileName);

            // 5. Save to Database
            ProductDAO dao = new ProductDAO();
            boolean isSaved = dao.addProduct(product);

            if (isSaved) {
                session.setAttribute("succMsg", "✅ Product added successfully!");
                resp.sendRedirect("adminProducts.jsp");
            } else {
                session.setAttribute("failedMsg", "Failed to add product to database!");
                resp.sendRedirect("addProduct.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
            resp.sendRedirect("addProduct.jsp");
        }
    }
}