package com.ecommerce.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ecommerce.model.User;
import com.ecommerce.model.Cart;
import com.ecommerce.model.Coupon;
import com.ecommerce.model.Order;
import com.ecommerce.dao.CartDAO;
import com.ecommerce.dao.OrderDAO;
import com.ecommerce.dao.ProductDAO;

@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        try {
            User user = (User) session.getAttribute("userobj");

            if (user == null) {
                session.setAttribute("failedMsg", "Please login to place an order!");
                resp.sendRedirect("login.jsp");
                return;
            }

            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String address = req.getParameter("address");
            String paymentType = req.getParameter("paymentType");

            if (name == null || name.trim().isEmpty()) name = user.getName();
            if (email == null || email.trim().isEmpty()) email = user.getEmail();
            if (phone == null || phone.trim().isEmpty()) phone = (user.getPhone() != null ? user.getPhone() : "");
            if (address == null || address.trim().isEmpty()) address = (user.getAddress() != null ? user.getAddress() : "Delivery Address");
            if (paymentType == null || paymentType.trim().isEmpty()) paymentType = "COD";

            CartDAO cartDao = new CartDAO();
            List<Cart> cartList = cartDao.getCartByUserId(user.getUserId());

            if (cartList == null || cartList.isEmpty()) {
                session.setAttribute("failedMsg", "Your cart is empty! Add products first.");
                resp.sendRedirect("cart.jsp");
                return;
            }

            // ⚠️ STEP 1: Pre-Order Stock Validation
            ProductDAO productDao = new ProductDAO();
            for (Cart c : cartList) {
                boolean isStockOk = productDao.checkStockAvailable(c.getProductId(), c.getQuantity());
                if (!isStockOk) {
                    String pName = c.getProductName() != null ? c.getProductName() : "One of your cart items";
                    session.setAttribute("failedMsg", "⚠️ Sorry, '" + pName + "' is either Out of Stock or does not have enough quantity available!");
                    resp.sendRedirect("cart.jsp");
                    return;
                }
            }

            // STEP 2: Subtotal Calculation
            double subTotal = 0;
            for (Cart c : cartList) {
                double itemTotal = (c.getTotalPrice() > 0) ? c.getTotalPrice() : (c.getPrice() * c.getQuantity());
                subTotal += itemTotal;
            }

            // STEP 3: Discount Retrieval
            double discountAmount = 0.0;
            String discountParam = req.getParameter("discountAmount");
            if (discountParam != null && !discountParam.trim().isEmpty()) {
                try { discountAmount = Double.parseDouble(discountParam.trim()); } catch (Exception e) {}
            }
            if (discountAmount <= 0) {
                Object discountObj = session.getAttribute("discountAmount");
                if (discountObj != null) {
                    try { discountAmount = Double.parseDouble(discountObj.toString()); } catch (Exception e) {}
                }
            }

            String couponCode = req.getParameter("couponCode");
            if (couponCode == null || couponCode.trim().isEmpty()) {
                Coupon cp = (Coupon) session.getAttribute("appliedCoupon");
                if (cp != null) couponCode = cp.getCouponCode();
            }

            if (discountAmount > subTotal) {
                discountAmount = subTotal;
            }

            // STEP 4: Build Order List
            List<Order> orderList = new ArrayList<>();
            for (Cart c : cartList) {
                Order order = new Order();
                order.setUserId(user.getUserId());
                order.setCustomerName(name);
                order.setEmail(email);
                order.setPhone(phone);
                order.setProductName(c.getProductName() != null ? c.getProductName() : "Product Item");

                double origItemTotal = (c.getTotalPrice() > 0) ? c.getTotalPrice() : (c.getPrice() * c.getQuantity());
                order.setPrice(origItemTotal);

                double itemDiscount = 0.0;
                if (subTotal > 0 && discountAmount > 0) {
                    itemDiscount = (origItemTotal / subTotal) * discountAmount;
                }
                itemDiscount = Math.round(itemDiscount * 100.0) / 100.0;
                order.setDiscountAmount(itemDiscount);
                order.setCouponCode(couponCode);

                double finalPayable = origItemTotal - itemDiscount;
                if (finalPayable < 0) finalPayable = 0;
                finalPayable = Math.round(finalPayable * 100.0) / 100.0;

                order.setTotalAmount(finalPayable);
                order.setPaymentType(paymentType);
                order.setStatus("Placed");
                order.setAddress(address);

                orderList.add(order);
            }

            // STEP 5: Save Orders into Database
            OrderDAO orderDao = new OrderDAO();
            boolean isSaved = orderDao.saveOrders(orderList);

            if (isSaved) {
                // 📦 STEP 6: Deduct Stock for each ordered product
                for (Cart c : cartList) {
                    productDao.deductStock(c.getProductId(), c.getQuantity());
                }

                // Clear cart and coupon from session
                cartDao.clearCartByUserId(user.getUserId());
                session.removeAttribute("appliedCoupon");
                session.removeAttribute("discountAmount");

                session.setAttribute("succMsg", "🎉 Order Placed Successfully! Inventory updated.");
                resp.sendRedirect("myOrders.jsp");
            } else {
                session.setAttribute("failedMsg", "Failed to save order in database. Please try again!");
                resp.sendRedirect("checkout.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
            resp.sendRedirect("checkout.jsp");
        }
    }
}