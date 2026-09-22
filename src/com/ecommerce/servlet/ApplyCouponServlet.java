package com.ecommerce.servlet;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.dao.CartDAO;
import com.ecommerce.dao.CouponDAO;
import com.ecommerce.model.Cart;
import com.ecommerce.model.Coupon;
import com.ecommerce.model.User;

@WebServlet("/ApplyCouponServlet")
public class ApplyCouponServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");
            if (user == null) {
                session.setAttribute("failedMsg", "Please login first!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String action = req.getParameter("action");

            // 1. Coupon Remove Action
            if ("remove".equalsIgnoreCase(action)) {
                session.removeAttribute("appliedCoupon");
                session.removeAttribute("discountAmount");
                session.setAttribute("succMsg", "Coupon removed successfully!");
                resp.sendRedirect("checkout.jsp");
                return;
            }

            // 2. Coupon Apply Action
            String promoCode = req.getParameter("promoCode");
            if (promoCode == null || promoCode.trim().isEmpty()) {
                session.setAttribute("failedMsg", "Please enter a valid coupon code!");
                resp.sendRedirect("checkout.jsp");
                return;
            }

            // Cart Total Calculate
            CartDAO cartDao = new CartDAO();
            List<Cart> cartList = cartDao.getCartByUserId(user.getUserId());
            double subTotal = 0;
            if (cartList != null) {
                for (Cart c : cartList) {
                    subTotal += (c.getTotalPrice() > 0) ? c.getTotalPrice() : (c.getPrice() * c.getQuantity());
                }
            }

            CouponDAO couponDao = new CouponDAO();
            Coupon coupon = couponDao.getCouponByCode(promoCode.trim());

            if (coupon == null) {
                session.setAttribute("failedMsg", "Invalid or expired coupon code: " + promoCode);
            } else if (subTotal < coupon.getMinOrderAmount()) {
                session.setAttribute("failedMsg", "Coupon '" + coupon.getCouponCode() + "' requires minimum order of ₹" + coupon.getMinOrderAmount());
            } else {
                // Calculate discount amount
                double discount = 0;
                if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
                    discount = (subTotal * coupon.getDiscountValue()) / 100.0;
                } else {
                    discount = coupon.getDiscountValue();
                }

                // Discount cannot exceed subtotal
                if (discount > subTotal) {
                    discount = subTotal;
                }

                session.setAttribute("appliedCoupon", coupon);
                session.setAttribute("discountAmount", discount);
                session.setAttribute("succMsg", "🎉 Coupon '" + coupon.getCouponCode() + "' applied! You saved ₹" + String.format("%.2f", discount));
            }

            resp.sendRedirect("checkout.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error applying coupon: " + e.getMessage());
            resp.sendRedirect("checkout.jsp");
        }
    }
}