package com.ecommerce.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.CartDAO;
import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Cart;
import com.ecommerce.model.Product;
import com.ecommerce.model.User;

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null) {
                session.setAttribute("failedMsg", "Please login first!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String cartIdStr = req.getParameter("cartId");
            String action = req.getParameter("action"); // "inc" or "dec"

            if (cartIdStr == null || cartIdStr.trim().isEmpty() || action == null) {
                resp.sendRedirect("cart.jsp");
                return;
            }

            int cartId = Integer.parseInt(cartIdStr.trim());
            CartDAO cartDao = new CartDAO();
            Cart cartItem = cartDao.getCartById(cartId);

            if (cartItem == null) {
                session.setAttribute("failedMsg", "Cart item not found!");
                resp.sendRedirect("cart.jsp");
                return;
            }

            int currentQty = cartItem.getQuantity();
            int newQty = currentQty;

            ProductDAO productDao = new ProductDAO();
            Product prod = productDao.getProductById(cartItem.getProductId());
            int availableStock = (prod != null) ? prod.getStock() : 0;
            double unitPrice = (prod != null && prod.getPrice() > 0) ? prod.getPrice() : cartItem.getPrice();

            if ("inc".equalsIgnoreCase(action)) {
                if (currentQty + 1 > availableStock) {
                    session.setAttribute("failedMsg", "⚠️ Only " + availableStock + " units available in stock!");
                    resp.sendRedirect("cart.jsp");
                    return;
                }
                newQty = currentQty + 1;
            } else if ("dec".equalsIgnoreCase(action)) {
                if (currentQty > 1) {
                    newQty = currentQty - 1;
                } else {
                    resp.sendRedirect("cart.jsp");
                    return;
                }
            }

            boolean isUpdated = cartDao.updateQuantity(cartId, newQty, unitPrice);

            if (!isUpdated) {
                session.setAttribute("failedMsg", "Database error: Could not update quantity.");
            }

            resp.sendRedirect("cart.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error updating cart: " + e.getMessage());
            resp.sendRedirect("cart.jsp");
        }
    }
}