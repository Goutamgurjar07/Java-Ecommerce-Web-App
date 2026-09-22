package com.ecommerce.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.WishlistDAO;
import com.ecommerce.model.User;

@WebServlet("/RemoveWishlistServlet")
public class RemoveWishlistServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null) {
                resp.sendRedirect("login.jsp");
                return;
            }

            String widStr = req.getParameter("wid");
            if (widStr != null && !widStr.trim().isEmpty()) {
                int wishlistId = Integer.parseInt(widStr.trim());
                WishlistDAO dao = new WishlistDAO();
                boolean isRemoved = dao.removeWishlistItem(wishlistId);

                if (isRemoved) {
                    session.setAttribute("succMsg", "Product removed from Wishlist.");
                } else {
                    session.setAttribute("failedMsg", "Failed to remove item.");
                }
            }

            resp.sendRedirect("wishlist.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("wishlist.jsp");
        }
    }
}