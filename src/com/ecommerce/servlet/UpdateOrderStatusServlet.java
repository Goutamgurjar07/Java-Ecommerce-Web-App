package com.ecommerce.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.model.User;
import com.ecommerce.dao.OrderDAO;

@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");

            // Admin Authorization Check
            if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("failedMsg", "Unauthorized Access! Admin login required.");
                resp.sendRedirect("login.jsp");
                return;
            }

            String orderIdParam = req.getParameter("orderId");
            String status = req.getParameter("status");

            if (orderIdParam == null || status == null || orderIdParam.trim().isEmpty() || status.trim().isEmpty()) {
                session.setAttribute("failedMsg", "Invalid order ID or status.");
                resp.sendRedirect("adminOrders.jsp");
                return;
            }

            int orderId = Integer.parseInt(orderIdParam.trim());

            OrderDAO dao = new OrderDAO();
            boolean f = dao.updateOrderStatus(orderId, status.trim());

            if (f) {
                session.setAttribute("succMsg", "✅ Order #ORD-" + orderId + " status updated to '" + status.trim() + "' successfully!");
            } else {
                session.setAttribute("failedMsg", "Failed to update order status in database.");
            }

            resp.sendRedirect("adminOrders.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error updating status: " + e.getMessage());
            resp.sendRedirect("adminOrders.jsp");
        }
    }
}