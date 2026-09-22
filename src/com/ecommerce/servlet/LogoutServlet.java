package com.ecommerce.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            HttpSession session = req.getSession();
            
            // 1. Session se User object ko remove karna
            session.removeAttribute("userobj");
            
            // 2. Poore session ko destroy karna
            session.invalidate();

            // 3. Naye session mein logout success message set karna
            HttpSession newSession = req.getSession();
            newSession.setAttribute("succMsg", "Logged out successfully!");

            // 4. Login page par redirect karna
            resp.sendRedirect("login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}