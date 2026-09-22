<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice Receipt - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        @media print {
            .no-print { display: none !important; }
            body { background-color: #ffffff !important; padding: 0 !important; }
            .invoice-card { box-shadow: none !important; border: 1px solid #dee2e6 !important; }
        }
        .invoice-card { max-width: 850px; margin: auto; }
    </style>
</head>
<body class="bg-light py-4">

    <%-- Session & Authorization Guard --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            session.setAttribute("failedMsg", "Please login to view order invoice!");
            response.sendRedirect("login.jsp");
            return;
        }

        String orderIdParam = request.getParameter("orderId");
        int orderId = 0;
        Order order = null;

        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                orderId = Integer.parseInt(orderIdParam.trim());
                OrderDAO dao = new OrderDAO();
                order = dao.getOrderById(orderId);
            } catch (Exception e) {
                order = null;
            }
        }

        if (order == null || (!"admin".equalsIgnoreCase(user.getRole()) && order.getUserId() != user.getUserId())) {
            session.setAttribute("failedMsg", "Invalid order or unauthorized access!");
            response.sendRedirect("myOrders.jsp");
            return;
        }

        double origPrice = order.getPrice() > 0 ? order.getPrice() : order.getTotalAmount();
        double finalAmount = order.getTotalAmount();
        double discountGiven = (origPrice > finalAmount) ? (origPrice - finalAmount) : 0.0;
    %>

    <div class="container mb-5">
        
        <!-- Action Buttons (Print / Back) -->
        <div class="d-flex justify-content-between align-items-center mb-4 no-print invoice-card">
            <a href="<%= "admin".equalsIgnoreCase(user.getRole()) ? "adminOrders.jsp" : "myOrders.jsp" %>" class="btn btn-outline-secondary fw-bold">
                ← Back to Orders
            </a>
            <button onclick="window.print()" class="btn btn-primary fw-bold px-4 shadow-sm">
                🖨️ Print / Download PDF
            </button>
        </div>

        <!-- Invoice Receipt Container -->
        <div class="card invoice-card shadow-sm border-0 rounded-4 p-4 p-md-5 bg-white">
            
            <!-- Invoice Header -->
            <div class="row align-items-center pb-4 border-bottom mb-4">
                <div class="col-sm-6">
                    <h2 class="fw-bold text-primary mb-1">🛒 E-Shop Store</h2>
                    <p class="text-muted small mb-0">Official Tax Invoice & Delivery Receipt</p>
                </div>
                <div class="col-sm-6 text-sm-end mt-3 mt-sm-0">
                    <h4 class="fw-bold text-dark mb-1">INVOICE</h4>
                    <span class="fw-semibold text-primary">#ORD-<%= order.getOrderId() %></span><br>
                    <small class="text-muted">Date: <%= order.getOrderDate() != null ? order.getOrderDate() : "N/A" %></small>
                </div>
            </div>

            <!-- Customer & Shipping Information -->
            <div class="row mb-4">
                <div class="col-sm-6 mb-3 mb-sm-0">
                    <h6 class="text-muted text-uppercase fw-bold small mb-2">Billed & Shipped To:</h6>
                    <h5 class="fw-bold text-dark mb-1"><%= order.getCustomerName() %></h5>
                    <p class="text-muted mb-1"><%= order.getAddress() %></p>
                    <small class="text-muted d-block">📞 Phone: <%= order.getPhone() %></small>
                    <small class="text-muted d-block">✉️ Email: <%= order.getEmail() %></small>
                </div>
                <div class="col-sm-6 text-sm-end">
                    <h6 class="text-muted text-uppercase fw-bold small mb-2">Payment & Delivery Info:</h6>
                    <p class="mb-1"><span class="fw-semibold">Payment Mode:</span> <span class="badge bg-secondary"><%= order.getPaymentType() %></span></p>
                    <p class="mb-1">
                        <span class="fw-semibold">Order Status:</span> 
                        <span class="badge <%= "Delivered".equalsIgnoreCase(order.getStatus()) ? "bg-success" : ("Cancelled".equalsIgnoreCase(order.getStatus()) ? "bg-danger" : "bg-warning text-dark") %>">
                            <%= order.getStatus() != null ? order.getStatus() : "Placed" %>
                        </span>
                    </p>
                </div>
            </div>

            <!-- Ordered Product Items Table -->
            <div class="table-responsive mb-4">
                <table class="table table-bordered align-middle">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Product Description</th>
                            <th class="text-center">Original Price</th>
                            <th class="text-end">Coupon Discount</th>
                            <th class="text-end pe-3">Paid Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="ps-3">1</td>
                            <td class="fw-bold text-dark"><%= order.getProductName() != null ? order.getProductName() : "Store Item" %></td>
                            <td class="text-center text-muted">₹<%= String.format("%.2f", origPrice) %></td>
                            <td class="text-end text-danger fw-semibold"><%= discountGiven > 0 ? "- ₹" + String.format("%.2f", discountGiven) : "₹0.00" %></td>
                            <td class="text-end pe-3 fw-bold text-success fs-6">₹<%= String.format("%.2f", finalAmount) %></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Total Price Calculation Breakdown -->
            <div class="row justify-content-end mb-4">
                <div class="col-md-5">
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-1">
                            <span class="text-muted">Original Subtotal:</span>
                            <span class="fw-semibold">₹<%= String.format("%.2f", origPrice) %></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-1">
                            <span class="text-muted">Coupon Discount:</span>
                            <span class="text-danger fw-bold">- ₹<%= String.format("%.2f", discountGiven) %></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-1">
                            <span class="text-muted">Shipping Charges:</span>
                            <span class="text-success fw-semibold">FREE</span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-top px-0 py-2 fs-5 fw-bold text-dark">
                            <span>Grand Total (Paid):</span>
                            <span class="text-success">₹<%= String.format("%.2f", finalAmount) %></span>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Invoice Footer Note -->
            <div class="border-top pt-3 text-center text-muted small">
                <p class="mb-1">Thank you for shopping with <strong>E-Shop</strong>!</p>
                <p class="mb-0">For any support, reach out to <strong>support@eshop.com</strong>.</p>
            </div>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>