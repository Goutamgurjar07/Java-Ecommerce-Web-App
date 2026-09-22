<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mock Razorpay Secure Checkout</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f6f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .payment-box { background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 400px; }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #eee; padding-bottom: 15px; margin-bottom: 20px; }
        .header h3 { margin: 0; color: #333; }
        .amount { font-size: 20px; font-weight: bold; color: #28a745; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-size: 14px; color: #666; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .pay-btn { background: #3399cc; color: white; border: none; width: 100%; padding: 12px; border-radius: 4px; font-size: 16px; cursor: pointer; font-weight: bold; }
        .pay-btn:hover { background: #287fa6; }
        .secure-text { text-align: center; font-size: 12px; color: #aaa; margin-top: 15px; }
    </style>
</head>
<body>

    <%
        // Checkout page se aane wale saare parameters ko safely variable mein store karna
        String amt = request.getParameter("amount");
        if (amt == null || amt.trim().isEmpty()) {
            amt = "500";
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String paymentMode = request.getParameter("paymentMode");
        if (paymentMode == null || paymentMode.trim().isEmpty()) {
            paymentMode = "ONLINE";
        }
    %>

    <div class="payment-box">
        <div class="header">
            <h3>Mock Razorpay</h3>
            <!-- Dynamic Amount Display -->
            <div class="amount">₹ <%= amt %></div>
        </div>
        
        <!-- Form jo payment successful hone ke baad PlaceOrderServlet ko data bhejega -->
        <form action="PlaceOrderServlet" method="post">
            <!-- 🟢 Sabhi zaroori hidden fields jo PlaceOrderServlet ke liye chahiye -->
            <input type="hidden" name="paymentMode" value="<%= paymentMode %>">
            <input type="hidden" name="razorpayPaymentId" value="pay_mock_<%= System.currentTimeMillis() %>">
            
            <!-- Amount ko dono keys se bhej rahe hain taaki servlet kabhi miss na kare -->
            <input type="hidden" name="amount" value="<%= amt %>">
            <input type="hidden" name="totalAmount" value="<%= amt %>">

            <!-- Customer details jo checkout se aayi thin -->
            <input type="hidden" name="name" value="<%= name != null ? name : "" %>">
            <input type="hidden" name="email" value="<%= email != null ? email : "" %>">
            <input type="hidden" name="phone" value="<%= phone != null ? phone : "" %>">
            <input type="hidden" name="address" value="<%= address != null ? address : "" %>">
            
            <div class="form-group">
                <label>Card Number (Enter any 16 digits)</label>
                <input type="text" value="4242 4242 4242 4242" maxlength="19" required>
            </div>
            
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex: 1;">
                    <label>Expiry</label>
                    <input type="text" value="12/28" required>
                </div>
                <div class="form-group" style="flex: 1;">
                    <label>CVV</label>
                    <input type="text" value="123" maxlength="3" required>
                </div>
            </div>
            
            <div class="form-group">
                <label>Cardholder Name</label>
                <input type="text" value="<%= name != null ? name : "Goutam Gurjar" %>" required>
            </div>
            
            <button type="submit" class="pay-btn">Pay Now & Complete Order</button>
        </form>
        
        <div class="secure-text">🔒 100% Secure Student Mock Gateway</div>
    </div>

</body>
</html>