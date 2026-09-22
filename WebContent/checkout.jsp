<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Cart" %>
<%@ page import="com.ecommerce.model.Coupon" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <%-- Session Verification & Calculation --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            session.setAttribute("failedMsg", "Please login to proceed with checkout!");
            response.sendRedirect("login.jsp");
            return;
        }

        CartDAO cartDao = new CartDAO();
        List<Cart> cartList = cartDao.getCartByUserId(user.getUserId());
        int cartCount = (cartList != null) ? cartList.size() : 0;

        if (cartList == null || cartList.isEmpty()) {
            session.setAttribute("failedMsg", "Your cart is empty! Add products first.");
            response.sendRedirect("cart.jsp");
            return;
        }

        double subTotal = 0;
        for (Cart c : cartList) {
            subTotal += (c.getTotalPrice() > 0) ? c.getTotalPrice() : (c.getPrice() * c.getQuantity());
        }

        // Coupon & Discount Calculation
        Coupon appliedCoupon = (Coupon) session.getAttribute("appliedCoupon");
        double discountAmount = 0.0;
        Object discountObj = session.getAttribute("discountAmount");
        if (discountObj != null) {
            try {
                discountAmount = Double.parseDouble(discountObj.toString());
            } catch (Exception e) {
                discountAmount = 0.0;
            }
        }

        double grandTotal = subTotal - discountAmount;
        if (grandTotal < 0) {
            grandTotal = 0;
        }

        String userName = user.getName() != null ? user.getName() : "";
        String userEmail = user.getEmail() != null ? user.getEmail() : "";
        String userPhone = user.getPhone() != null ? user.getPhone() : "";
        String userAddress = user.getAddress() != null ? user.getAddress() : "";
    %>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4" href="index.jsp">🛒 E-Shop</a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="index.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="myOrders.jsp">📦 My Orders</a></li>
                </ul>

                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item me-3">
                        <a href="cart.jsp" class="btn btn-light text-primary position-relative fw-bold">
                            🛒 Cart
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                <%= cartCount %>
                            </span>
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-warning fw-bold btn btn-outline-light text-warning px-3 py-1 border-warning rounded-pill" 
                           href="#" id="userMenuDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            👤 Welcome, <%= userName %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 rounded-3 mt-2">
                            <li><a class="dropdown-item fw-semibold py-2" href="profile.jsp">👤 My Profile & Security</a></li>
                            <li><a class="dropdown-item fw-semibold py-2" href="myOrders.jsp">📦 My Orders</a></li>
                            <li><a class="dropdown-item fw-semibold text-danger py-2" href="LogoutServlet">🚪 Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Alert Messages Banner -->
    <div class="container">
        <% 
            String errorMsg = (String) session.getAttribute("failedMsg");
            String succMsg = (String) session.getAttribute("succMsg");
            if (errorMsg != null) { 
        %>
            <div class="alert alert-danger alert-dismissible fade show text-center fw-bold" role="alert">
                ❌ <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% session.removeAttribute("failedMsg"); } %>
        <% if (succMsg != null) { %>
            <div class="alert alert-success alert-dismissible fade show text-center fw-bold" role="alert">
                <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% session.removeAttribute("succMsg"); } %>
    </div>

    <!-- Main Checkout Section -->
    <div class="container my-4 mb-5">
        <h3 class="fw-bold text-primary mb-4">💳 Checkout & Order Summary</h3>

        <div class="row g-4">
            
            <!-- Left Side: Items Summary & Promo Code Box -->
            <div class="col-lg-5">
                
                <!-- 1. Cart Items -->
                <div class="card shadow-sm border-0 rounded-4 mb-3">
                    <div class="card-header bg-white py-3 border-bottom">
                        <h5 class="fw-bold text-dark mb-0">📦 Order Items (<%= cartCount %>)</h5>
                    </div>
                    <div class="card-body p-0">
                        <ul class="list-group list-group-flush">
                            <% for (Cart c : cartList) { 
                                double itemTotal = (c.getTotalPrice() > 0) ? c.getTotalPrice() : (c.getPrice() * c.getQuantity());
                            %>
                                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                                    <div>
                                        <h6 class="fw-bold mb-0"><%= c.getProductName() %></h6>
                                        <small class="text-muted">Qty: <%= c.getQuantity() %> x ₹<%= c.getPrice() %></small>
                                    </div>
                                    <span class="fw-bold text-dark">₹<%= itemTotal %></span>
                                </li>
                            <% } %>
                        </ul>
                    </div>
                </div>

                <!-- 2. Promo Code Box -->
                <div class="card shadow-sm border-0 rounded-4 mb-3">
                    <div class="card-body p-3">
                        <h6 class="fw-bold text-dark mb-2">🏷️ Apply Coupon / Promo Code</h6>
                        
                        <% if (appliedCoupon == null) { %>
                            <form action="ApplyCouponServlet" method="post" class="d-flex gap-2">
                                <input type="hidden" name="action" value="apply">
                                <input type="text" name="promoCode" class="form-control text-uppercase fw-bold" placeholder="e.g. SAVE10 / FLAT100" required>
                                <button type="submit" class="btn btn-warning fw-bold px-3">Apply</button>
                            </form>
                            <small class="text-muted d-block mt-2">Available: <strong>SAVE10</strong> (10% off), <strong>FLAT100</strong> (₹100 off)</small>
                        <% } else { %>
                            <div class="d-flex justify-content-between align-items-center bg-success-subtle p-2 px-3 rounded-3 border border-success-subtle">
                                <div>
                                    <span class="badge bg-success me-1">APPLIED</span>
                                    <strong class="text-success text-uppercase"><%= appliedCoupon.getCouponCode() %></strong>
                                    <small class="text-muted d-block">Saved ₹<%= String.format("%.2f", discountAmount) %></small>
                                </div>
                                <form action="ApplyCouponServlet" method="post" class="m-0">
                                    <input type="hidden" name="action" value="remove">
                                    <button type="submit" class="btn btn-outline-danger btn-sm fw-bold">✕ Remove</button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- 3. Price Breakdown -->
                <div class="card shadow-sm border-0 rounded-4">
                    <div class="card-body p-3">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                                <span class="text-muted">Subtotal:</span>
                                <span class="fw-semibold">₹<%= String.format("%.2f", subTotal) %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                                <span class="text-muted">Coupon Discount:</span>
                                <span class="text-danger fw-bold">- ₹<%= String.format("%.2f", discountAmount) %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                                <span class="text-muted">Delivery Charges:</span>
                                <span class="text-success fw-bold">FREE</span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between border-top px-0 py-3 fs-4 fw-bold text-dark">
                                <span>Total Payable:</span>
                                <span class="text-success">₹<%= String.format("%.2f", grandTotal) %></span>
                            </li>
                        </ul>
                    </div>
                </div>

            </div>

            <!-- Right Side: Delivery Form -->
            <div class="col-lg-7">
                <div class="card shadow-sm border-0 rounded-4">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-primary mb-0">📍 Delivery Address & Payment</h5>
                        <span class="badge bg-light text-muted border">Auto-Filled from Profile</span>
                    </div>
                    <div class="card-body p-4">
                        <form action="OrderServlet" method="post">
                            <!-- ✅ Explicit Hidden Inputs for Guaranteed Discount Delivery -->
                            <input type="hidden" name="discountAmount" value="<%= discountAmount %>">
                            <input type="hidden" name="couponCode" value="<%= appliedCoupon != null ? appliedCoupon.getCouponCode() : "" %>">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Full Name</label>
                                    <input type="text" class="form-control" name="name" value="<%= userName %>" placeholder="Enter full name" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email Address</label>
                                    <input type="email" class="form-control" name="email" value="<%= userEmail %>" placeholder="Enter email" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Phone Number</label>
                                    <input type="tel" class="form-control" name="phone" value="<%= userPhone %>" placeholder="10-digit mobile number" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Payment Mode</label>
                                    <select class="form-select fw-semibold" name="paymentType" required>
                                        <option value="COD" selected>💵 Cash On Delivery (COD)</option>
                                        <option value="UPI">📱 UPI / Net Banking</option>
                                        <option value="CARD">💳 Credit / Debit Card</option>
                                    </select>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Complete Delivery Address</label>
                                    <textarea class="form-control" name="address" rows="3" placeholder="House No., Street, City, State - Pincode" required><%= userAddress %></textarea>
                                </div>

                                <div class="col-12 mt-4">
                                    <button type="submit" class="btn btn-success btn-lg w-100 fw-bold shadow-sm py-3">
                                        🚀 Place Order Now (₹<%= String.format("%.2f", grandTotal) %>)
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>