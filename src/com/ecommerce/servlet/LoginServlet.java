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

// URL Mapping Annotation
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. Login form se credentials receive karna
            String email = req.getParameter("email");
            String password = req.getParameter("password");

            // 2. Database mein User check karna
            UserDAO dao = new UserDAO();
            User user = dao.loginUser(email, password);

            HttpSession session = req.getSession();

            if (user != null) {
                // Login Success: Session mein User object store karna (User identity maintain karne ke liye)
                session.setAttribute("userobj", user);

                // Role Based Redirection (Admin vs Customer)
                if ("admin".equalsIgnoreCase(user.getRole())) {
                    resp.sendRedirect("index.jsp"); // Ya Admin Dashboard Page
                } else {
                    resp.sendRedirect("index.jsp"); // Customer Homepage
                }

            } else {
                // Login Failed
                session.setAttribute("failedMsg", "Invalid Email or Password!");
                resp.sendRedirect("login.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}