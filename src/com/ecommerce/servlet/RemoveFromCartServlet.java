package com.ecommerce.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.ecommerce.dao.CartDAO;

@WebServlet("/RemoveFromCartServlet")
public class RemoveFromCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int cartId = Integer.parseInt(req.getParameter("cartId"));
        
        CartDAO dao = new CartDAO();
        boolean status = dao.removeCartItem(cartId);
        
        HttpSession session = req.getSession();
        if (status) {
            session.setAttribute("succMsg", "Item removed from cart!");
        } else {
            session.setAttribute("failedMsg", "Something went wrong!");
        }
        
        resp.sendRedirect("cart.jsp");
    }
}