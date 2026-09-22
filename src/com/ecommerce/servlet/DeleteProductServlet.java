package com.ecommerce.servlet;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Product;
import com.ecommerce.model.User;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");

            // 1. Admin Security Check
            if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("failedMsg", "Unauthorized Access! Admin login required.");
                resp.sendRedirect("login.jsp");
                return;
            }

            // 2. Safe Extraction of Parameter (Checking both 'id' and 'pid')
            String idStr = req.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                idStr = req.getParameter("pid");
            }

            // 3. Null / Empty Validation (Crash Prevention)
            if (idStr == null || idStr.trim().isEmpty()) {
                session.setAttribute("failedMsg", "Product ID missing or invalid!");
                resp.sendRedirect("adminProducts.jsp");
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(idStr.trim());
            } catch (NumberFormatException nfe) {
                session.setAttribute("failedMsg", "Invalid Product ID format: " + idStr);
                resp.sendRedirect("adminProducts.jsp");
                return;
            }

            // 4. Product Fetch & Image Name Retrieve
            ProductDAO dao = new ProductDAO();
            Product product = dao.getProductById(productId);

            // 5. Database Delete Execution
            boolean isDeleted = dao.deleteProduct(productId);

            if (isDeleted) {
                // 6. Server Storage Image Cleanup
                if (product != null && product.getImageName() != null && !product.getImageName().trim().isEmpty()) {
                    String imgName = product.getImageName().trim();
                    if (!"default.png".equalsIgnoreCase(imgName)) {
                        try {
                            String uploadPath = req.getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + imgName;
                            File imgFile = new File(uploadPath);
                            if (imgFile.exists()) {
                                imgFile.delete();
                            }
                        } catch (Exception ex) {
                            // File deletion error won't interrupt response
                        }
                    }
                }

                session.setAttribute("succMsg", "🗑️ Product '" + (product != null ? product.getName() : "Item") + "' deleted successfully!");
            } else {
                session.setAttribute("failedMsg", "Failed to delete product from database.");
            }

            resp.sendRedirect("adminProducts.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error deleting product: " + e.getMessage());
            resp.sendRedirect("adminProducts.jsp");
        }
    }
}