<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Manage Customer Orders</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <%-- Admin Access Protection --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("failedMsg", "Unauthorized Access! Admin login required.");
            response.sendRedirect("login.jsp");
            return;
        }

        OrderDAO orderDao = new OrderDAO();
        List<Order> allOrders = orderDao.getAllOrders();
        int totalOrders = (allOrders != null) ? allOrders.size() : 0;
    %>

    <!-- Admin Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4 text-warning" href="adminDashboard.jsp">⚙️ Admin Panel</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="adminNavbar">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold" href="adminDashboard.jsp">📊 Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-info fw-bold" href="adminProducts.jsp">📦 Manage Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-warning fw-bold" href="addProduct.jsp">➕ Add Product</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold active text-warning" href="adminOrders.jsp">📋 Customer Orders</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item me-3 text-white fw-semibold">
                        👑 Admin: <span class="text-warning fw-bold"><%= user.getName() %></span>
                    </li>
                    <li class="nav-item me-2">
                        <a class="btn btn-outline-light btn-sm fw-bold" href="index.jsp">🌐 Store Front</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-danger fw-bold btn-sm" href="LogoutServlet">Logout</a>
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
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% 
                session.removeAttribute("failedMsg");
            } 
            if (succMsg != null) { 
        %>
            <div class="alert alert-success alert-dismissible fade show text-center fw-bold" role="alert">
                ✅ <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% 
                session.removeAttribute("succMsg");
            } 
        %>
    </div>

    <!-- Main Content: All Customer Orders Table -->
    <div class="container-fluid px-4 my-4 mb-5">
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
            <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                <div>
                    <h3 class="fw-bold text-dark mb-0">📋 All Customer Placed Orders</h3>
                    <small class="text-muted">Manage real-time order status and view customer invoices</small>
                </div>
                <span class="badge bg-primary fs-6 px-3 py-2">Total Orders: <%= totalOrders %></span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th scope="col" class="ps-4">Order ID</th>
                                <th scope="col">Customer Info</th>
                                <th scope="col">Product Name</th>
                                <th scope="col">Shipping Address</th>
                                <th scope="col" class="text-center">Payment</th>
                                <th scope="col" class="text-center">Paid Amount</th>
                                <th scope="col">Date & Time</th>
                                <th scope="col" class="text-center pe-4" style="min-width: 250px;">Status & Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (allOrders != null && !allOrders.isEmpty()) {
                                    for (Order ord : allOrders) {
                                        String currentStatus = ord.getStatus() != null ? ord.getStatus().trim() : "Placed";
                                        
                                        // Badge Color Logic
                                        String badgeClass = "bg-secondary";
                                        if ("Placed".equalsIgnoreCase(currentStatus) || "Pending".equalsIgnoreCase(currentStatus)) {
                                            badgeClass = "bg-warning text-dark";
                                        } else if ("Processing".equalsIgnoreCase(currentStatus)) {
                                            badgeClass = "bg-info text-dark";
                                        } else if ("Shipped".equalsIgnoreCase(currentStatus)) {
                                            badgeClass = "bg-primary";
                                        } else if ("Delivered".equalsIgnoreCase(currentStatus)) {
                                            badgeClass = "bg-success";
                                        } else if ("Cancelled".equalsIgnoreCase(currentStatus)) {
                                            badgeClass = "bg-danger";
                                        }
                            %>
                            <tr>
                                <td class="ps-4 fw-bold text-primary">#ORD-<%= ord.getOrderId() %></td>
                                <td>
                                    <div class="fw-bold text-dark"><%= ord.getCustomerName() %></div>
                                    <small class="text-muted">✉️ <%= ord.getEmail() %></small><br>
                                    <small class="text-muted">📞 <%= ord.getPhone() %></small>
                                </td>
                                <td>
                                    <span class="fw-semibold text-dark"><%= ord.getProductName() != null ? ord.getProductName() : "Product Item" %></span>
                                </td>
                                <td style="max-width: 220px;">
                                    <small class="text-dark"><%= ord.getAddress() %></small>
                                </td>
                                <td class="text-center">
                                    <span class="badge bg-secondary px-3 py-2"><%= ord.getPaymentType() %></span>
                                </td>
                                <td class="text-center">
                                    <span class="fw-bold text-success fs-6">₹<%= String.format("%.2f", ord.getTotalAmount()) %></span>
                                    <% if (ord.getCouponCode() != null && !ord.getCouponCode().trim().isEmpty()) { %>
                                        <small class="badge bg-success-subtle text-success border border-success-subtle d-block mt-1">Code: <%= ord.getCouponCode() %></small>
                                    <% } %>
                                </td>
                                <td class="small text-muted"><%= ord.getOrderDate() != null ? ord.getOrderDate() : "" %></td>
                                <td class="pe-4">
                                    <div class="d-flex align-items-center justify-content-center gap-2">
                                        <!-- Status Update Form -->
                                        <form action="UpdateOrderStatusServlet" method="post" class="d-flex align-items-center gap-1 m-0">
                                            <input type="hidden" name="orderId" value="<%= ord.getOrderId() %>">
                                            <select name="status" class="form-select form-select-sm fw-semibold" style="width: 130px;" required>
                                                <option value="Placed" <%= "Placed".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Placed</option>
                                                <option value="Processing" <%= "Processing".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Processing</option>
                                                <option value="Shipped" <%= "Shipped".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Shipped</option>
                                                <option value="Delivered" <%= "Delivered".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Delivered</option>
                                                <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Cancelled</option>
                                            </select>
                                            <button type="submit" class="btn btn-warning btn-sm fw-bold">Save</button>
                                        </form>

                                        <!-- Invoice Button -->
                                        <a href="orderInvoice.jsp?orderId=<%= ord.getOrderId() %>" class="btn btn-outline-dark btn-sm fw-bold" title="View Customer Invoice">
                                            📄
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% 
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="8" class="text-center py-5">
                                    <h4 class="text-muted fw-bold">No orders placed by any customer yet! 📦</h4>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>