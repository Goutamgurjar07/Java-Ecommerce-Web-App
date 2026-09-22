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

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.dao.CartDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.User;

@WebServlet("/PlaceOrderServlet")
public class PlaceOrderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        
        // 1. Session se user fetch karne ke multiple tareeqe (Fallback safety)
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            user = (User) session.getAttribute("user");
        }

        // 2. Agar session clear ho gaya ho, toh form parameters se user object bana lo taaki login page par na bhej sake
        if (user == null) {
            String formName = req.getParameter("name");
            String formEmail = req.getParameter("email");
            String formPhone = req.getParameter("phone");
            String formAddress = req.getParameter("address");

            if (formEmail != null && !formEmail.trim().isEmpty()) {
                user = new User();
                user.setUserId(1); // Default fallback ID agar session gayab ho
                user.setName(formName != null && !formName.isEmpty() ? formName : "Valued Customer");
                user.setEmail(formEmail);
                user.setPhone(formPhone);
                user.setAddress(formAddress);
            }
        }

        // Agar phir bhi user na mile, tabhi login par bhejo
        if (user == null) {
            session.setAttribute("failedMsg", "Session expired! Please login again to place order.");
            resp.sendRedirect("login.jsp");
            return;
        }

        try {
            // Form parameters fetch karna
            String address = req.getParameter("address");
            if (address == null || address.trim().isEmpty()) {
                address = user.getAddress();
            }

            String phone = req.getParameter("phone");
            if (phone == null || phone.trim().isEmpty()) {
                phone = user.getPhone();
            }
            
            String amountStr = req.getParameter("amount");
            double amount = 0.0;
            if (amountStr != null && !amountStr.trim().isEmpty()) {
                amount = Double.parseDouble(amountStr);
            }

            String paymentMode = req.getParameter("paymentMode"); // "COD", "UPI", "CARD"
            if (paymentMode == null) {
                paymentMode = "ONLINE";
            }
            
            String razorpayPaymentId = req.getParameter("razorpayPaymentId");

            // Order Object Create karna
            Order order = new Order();
            order.setUserId(user.getUserId() > 0 ? user.getUserId() : 1);
            order.setCustomerName(user.getName() != null ? user.getName() : "Customer");
            order.setEmail(user.getEmail() != null ? user.getEmail() : "user@eshop.com");
            order.setPhone(phone != null ? phone : "9999999999");
            order.setAddress(address != null ? address : "India");
            order.setPrice(amount);           
            order.setTotalAmount(amount);     
            order.setPaymentType(paymentMode);

            // Payment Mode ke hisaab se Status set karna
            if ("UPI".equalsIgnoreCase(paymentMode) || "CARD".equalsIgnoreCase(paymentMode) || "ONLINE".equalsIgnoreCase(paymentMode)) {
                order.setStatus("Paid");
                if (razorpayPaymentId == null || razorpayPaymentId.trim().isEmpty()) {
                    razorpayPaymentId = "MOCK_PAY_" + System.currentTimeMillis();
                }
                order.setRazorpayPaymentId(razorpayPaymentId);
            } else {
                order.setStatus("Placed");
                order.setRazorpayPaymentId(null);
            }

            // OrderDAO list accept karta hai
            List<Order> orderList = new ArrayList<>();
            orderList.add(order);

            OrderDAO dao = new OrderDAO();
            boolean isSaved = dao.saveOrders(orderList);

            if (isSaved) {
                // Cart clear karne ka code safely run karega
                try {
                    CartDAO cartDao = new CartDAO();
                    cartDao.clearCartByUserId(user.getUserId()); 
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                // Session se coupon data clear karein
                session.removeAttribute("appliedCoupon");
                session.removeAttribute("discountAmount");

                session.setAttribute("succMsg", "Order placed successfully!");
                resp.sendRedirect("orderSuccess.jsp");
            } else {
                session.setAttribute("failedMsg", "Order placing failed in database! Please try again.");
                resp.sendRedirect("checkout.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "An error occurred: " + e.getMessage());
            resp.sendRedirect("checkout.jsp");
        }
    }
}