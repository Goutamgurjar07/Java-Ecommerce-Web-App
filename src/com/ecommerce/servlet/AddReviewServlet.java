package com.ecommerce.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.dao.ReviewDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.Review;
import com.ecommerce.model.User;

@WebServlet("/AddReviewServlet")
public class AddReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null) {
                session.setAttribute("failedMsg", "Please login to submit a review!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String productName = req.getParameter("productName");
            String orderIdStr = req.getParameter("orderId");
            String ratingStr = req.getParameter("rating");
            String reviewText = req.getParameter("reviewText");

            // Backup resolution: agar productName null ya empty ho toh orderId se nikalo
            if ((productName == null || productName.trim().isEmpty() || "null".equalsIgnoreCase(productName.trim())) 
                    && (orderIdStr != null && !orderIdStr.trim().isEmpty())) {
                try {
                    int orderId = Integer.parseInt(orderIdStr.trim());
                    OrderDAO orderDao = new OrderDAO();
                    Order ord = orderDao.getOrderById(orderId);
                    if (ord != null && ord.getProductName() != null) {
                        productName = ord.getProductName().trim();
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            if (productName == null || productName.trim().isEmpty() || "null".equalsIgnoreCase(productName.trim())) {
                productName = "Product Item";
            }

            int rating = 5;
            if (ratingStr != null && !ratingStr.trim().isEmpty()) {
                try {
                    rating = Integer.parseInt(ratingStr.trim());
                } catch (Exception e) {
                    rating = 5;
                }
            }
            if (rating < 1) rating = 1;
            if (rating > 5) rating = 5;

            if (reviewText == null || reviewText.trim().isEmpty()) {
                session.setAttribute("failedMsg", "Please write some feedback before submitting!");
                resp.sendRedirect("myOrders.jsp");
                return;
            }

            Review review = new Review();
            review.setUserId(user.getUserId());
            review.setProductName(productName);
            review.setUserName(user.getName() != null ? user.getName() : "Customer");
            review.setRating(rating);
            review.setReviewText(reviewText.trim());

            ReviewDAO dao = new ReviewDAO();
            boolean isSaved = dao.addReview(review);

            if (isSaved) {
                session.setAttribute("succMsg", "⭐ Thank you! Your review for '" + productName + "' has been submitted!");
            } else {
                session.setAttribute("failedMsg", "Failed to submit review. Please try again.");
            }

            resp.sendRedirect("myOrders.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error submitting review: " + e.getMessage());
            resp.sendRedirect("myOrders.jsp");
        }
    }
}