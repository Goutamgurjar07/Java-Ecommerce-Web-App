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

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            HttpSession session = req.getSession();
            User user = (User) session.getAttribute("userobj");

            // 1. Check user login status
            if (user == null) {
                session.setAttribute("failedMsg", "Please login to add items to cart!");
                resp.sendRedirect("login.jsp");
                return;
            }

            int pid = Integer.parseInt(req.getParameter("pid"));
            int uid = user.getUserId();

            // 2. Product Details Fetch karein
            ProductDAO pdao = new ProductDAO();
            Product product = pdao.getProductById(pid);

            if (product != null) {
                Cart cart = new Cart();
                cart.setUserId(uid);
                cart.setProductId(pid);
                cart.setPrice(product.getPrice());

                // 3. Save / Update in Cart Database
                CartDAO cdao = new CartDAO();
                boolean status = cdao.addToCart(cart);

                if (status) {
                    session.setAttribute("succMsg", "Item added to cart successfully!");
                } else {
                    session.setAttribute("failedMsg", "Failed to add item to cart!");
                }
            } else {
                session.setAttribute("failedMsg", "Product not found!");
            }

            resp.sendRedirect("index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("index.jsp");
        }
    }
}