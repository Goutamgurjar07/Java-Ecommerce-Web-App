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
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. JSP Form se data receive karna (Form field names ke same hona chahiye)
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");

            // 2. User Model object create karna (Default role 'customer')
            User user = new User(name, email, password, phone, address, "customer");

            // 3. DAO Object ke through DB mein register karna
            UserDAO dao = new UserDAO();
            boolean status = dao.registerUser(user);

            // 4. Session object message display karne ke liye
            HttpSession session = req.getSession();

            if (status) {
                session.setAttribute("succMsg", "Registration Successful! Please Login.");
                resp.sendRedirect("login.jsp"); // Redirecting to Login Page
            } else {
                session.setAttribute("failedMsg", "Something went wrong on server!");
                resp.sendRedirect("register.jsp"); // Back to Register Page
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}