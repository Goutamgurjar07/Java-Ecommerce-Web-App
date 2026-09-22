package com.ecommerce.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.model.User;
import com.ecommerce.dao.UserDAO;

@WebServlet("/UpdateUserServlet")
public class UpdateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User currentUser = (User) session.getAttribute("userobj");

            if (currentUser == null) {
                session.setAttribute("failedMsg", "Session expired! Please login again.");
                resp.sendRedirect("login.jsp");
                return;
            }

            String action = req.getParameter("action");
            UserDAO dao = new UserDAO();

            // Action 1: Profile & Delivery Address Update
            if ("updateProfile".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String address = req.getParameter("address"); // ✅ Added Address parameter

                User updatedUser = new User();
                updatedUser.setUserId(currentUser.getUserId());
                updatedUser.setName(name);
                updatedUser.setEmail(email);
                updatedUser.setPhone(phone);
                updatedUser.setAddress(address); // ✅ Set address in model

                boolean f = dao.updateUserProfile(updatedUser);
                if (f) {
                    // Session User Object Refresh
                    currentUser.setName(name);
                    currentUser.setEmail(email);
                    currentUser.setPhone(phone);
                    currentUser.setAddress(address); // ✅ Update session address
                    session.setAttribute("userobj", currentUser);

                    session.setAttribute("succMsg", "Profile & Address updated successfully! ✅");
                } else {
                    session.setAttribute("failedMsg", "Failed to update profile. Please try again!");
                }
            } 
            // Action 2: Password Change
            else if ("changePassword".equalsIgnoreCase(action)) {
                String oldPass = req.getParameter("oldPassword");
                String newPass = req.getParameter("newPassword");

                boolean f = dao.checkAndChangePassword(currentUser.getUserId(), oldPass, newPass);
                if (f) {
                    currentUser.setPassword(newPass);
                    session.setAttribute("userobj", currentUser);

                    session.setAttribute("succMsg", "Password changed successfully! 🔑");
                } else {
                    session.setAttribute("failedMsg", "Incorrect Old Password! Please try again.");
                }
            }

            resp.sendRedirect("profile.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
            resp.sendRedirect("profile.jsp");
        }
    }
}