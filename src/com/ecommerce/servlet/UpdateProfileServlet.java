package com.ecommerce.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null) {
                session.setAttribute("failedMsg", "Please login to update your profile!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String action = req.getParameter("action");
            UserDAO dao = new UserDAO();

            // Action 1: Update Personal Information
            if ("updateDetails".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String phone = req.getParameter("phone");
                String address = req.getParameter("address");

                if (name == null || name.trim().isEmpty()) {
                    session.setAttribute("failedMsg", "Name cannot be empty!");
                    resp.sendRedirect("profile.jsp");
                    return;
                }

                user.setName(name.trim());
                user.setPhone(phone != null ? phone.trim() : "");
                user.setAddress(address != null ? address.trim() : "");

                boolean isUpdated = dao.updateUserProfile(user);
                if (isUpdated) {
                    // Update the session object with new values
                    session.setAttribute("userobj", user);
                    session.setAttribute("succMsg", "✅ Profile details updated successfully!");
                } else {
                    session.setAttribute("failedMsg", "Failed to update profile in database.");
                }

            // Action 2: Change Password
            } else if ("changePassword".equalsIgnoreCase(action)) {
                String oldPass = req.getParameter("oldPassword");
                String newPass = req.getParameter("newPassword");
                String confirmPass = req.getParameter("confirmPassword");

                if (oldPass == null || newPass == null || confirmPass == null || 
                    oldPass.trim().isEmpty() || newPass.trim().isEmpty() || confirmPass.trim().isEmpty()) {
                    session.setAttribute("failedMsg", "All password fields are required!");
                    resp.sendRedirect("profile.jsp");
                    return;
                }

                if (!newPass.equals(confirmPass)) {
                    session.setAttribute("failedMsg", "New Password and Confirm Password do not match!");
                    resp.sendRedirect("profile.jsp");
                    return;
                }

                if (newPass.length() < 4) {
                    session.setAttribute("failedMsg", "New password must be at least 4 characters long!");
                    resp.sendRedirect("profile.jsp");
                    return;
                }

                boolean isChanged = dao.changePassword(user.getUserId(), oldPass.trim(), newPass.trim());
                if (isChanged) {
                    user.setPassword(newPass.trim());
                    session.setAttribute("userobj", user);
                    session.setAttribute("succMsg", "🔑 Password changed successfully!");
                } else {
                    session.setAttribute("failedMsg", "Incorrect current password! Please verify and try again.");
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