package com.ecommerce.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String query = req.getParameter("ch");
        if (query != null && !query.trim().isEmpty()) {
            resp.sendRedirect("index.jsp?search=" + java.net.URLEncoder.encode(query.trim(), "UTF-8"));
        } else {
            resp.sendRedirect("index.jsp");
        }
    }
}