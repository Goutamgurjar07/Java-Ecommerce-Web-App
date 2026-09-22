package com.ecommerce.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.User;

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");

            // User Login Guard Check
            if (user == null) {
                session.setAttribute("failedMsg", "Please login first!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
                session.setAttribute("failedMsg", "Invalid Order ID!");
                resp.sendRedirect("myOrders.jsp");
                return;
            }

            int orderId = Integer.parseInt(orderIdStr.trim());

            OrderDAO dao = new OrderDAO();
            boolean isCancelled = dao.cancelOrder(orderId, user.getUserId());

            if (isCancelled) {
                session.setAttribute("succMsg", "Order #ORD-" + orderId + " cancelled successfully!");
            } else {
                session.setAttribute("failedMsg", "Order cannot be cancelled (already Shipped, Delivered or Cancelled).");
            }

            resp.sendRedirect("myOrders.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error cancelling order: " + e.getMessage());
            resp.sendRedirect("myOrders.jsp");
        }
    }
}