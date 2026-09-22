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

@WebServlet("/AddToWishlistServlet")
public class AddToWishlistServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null) {
                session.setAttribute("failedMsg", "Please login first to save items to your wishlist!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String pidStr = req.getParameter("pid");
            if (pidStr == null || pidStr.trim().isEmpty()) {
                resp.sendRedirect("index.jsp");
                return;
            }

            int productId = Integer.parseInt(pidStr.trim());
            WishlistDAO dao = new WishlistDAO();

            if (dao.checkWishlist(user.getUserId(), productId)) {
                session.setAttribute("failedMsg", "This product is already in your wishlist!");
            } else {
                boolean isAdded = dao.addToWishlist(user.getUserId(), productId);
                if (isAdded) {
                    session.setAttribute("succMsg", "❤️ Product added to your Wishlist!");
                } else {
                    session.setAttribute("failedMsg", "Could not add product to wishlist.");
                }
            }

            String referer = req.getHeader("referer");
            if (referer != null && !referer.trim().isEmpty()) {
                resp.sendRedirect(referer);
            } else {
                resp.sendRedirect("wishlist.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
            resp.sendRedirect("index.jsp");
        }
    }
}