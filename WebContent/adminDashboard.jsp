<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.dao.AdminDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard & Analytics - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .stat-card {
            border-radius: 16px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.08) !important;
        }
        .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
    </style>
</head>
<body class="bg-light">

    <%-- Admin Guard Check --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("failedMsg", "Unauthorized Access! Admin login required.");
            response.sendRedirect("login.jsp");
            return;
        }

        AdminDAO adminDao = new AdminDAO();
        double totalRevenue = adminDao.getTotalRevenue();
        int totalOrders = adminDao.getTotalOrdersCount();
        int totalUsers = adminDao.getTotalUsersCount();

        List<Product> lowStockList = adminDao.getLowStockProducts(5);
        int lowStockCount = (lowStockList != null) ? lowStockList.size() : 0;

        List<Map<String, Object>> topSellingList = adminDao.getTopSellingProducts(5);
        List<Order> recentOrders = adminDao.getRecentOrders(5);
    %>

    <!-- ⚙️ Admin Dedicated Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4 text-warning" href="adminDashboard.jsp">⚙️ Admin Panel</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="adminNavbar">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link text-warning active fw-bold" href="adminDashboard.jsp">📊 Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold" href="adminProducts.jsp">📦 Manage Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold" href="addProduct.jsp">➕ Add Product</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold" href="adminOrders.jsp">📋 Manage Orders</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item me-3 text-white fw-semibold">
                        👑 Admin: <span class="text-warning fw-bold"><%= user.getName() %></span>
                    </li>
                    <li class="nav-item me-2">
                        <a class="btn btn-outline-light btn-sm fw-bold" href="index.jsp">🌐 Storefront</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-danger fw-bold btn-sm" href="LogoutServlet">Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="container mb-5">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-1">📊 Sales Analytics & Performance Overview</h3>
                <small class="text-muted">Live metrics calculated directly from database</small>
            </div>
            <a href="adminOrders.jsp" class="btn btn-primary fw-bold btn-sm px-3 shadow-sm">
                Manage All Orders →
            </a>
        </div>

        <!-- 4 KPI Summary Cards -->
        <div class="row g-3 mb-4">
            
            <!-- Revenue Card -->
            <div class="col-sm-6 col-xl-3">
                <div class="card stat-card border-0 shadow-sm p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted fw-semibold small d-block">TOTAL REVENUE</span>
                            <h4 class="fw-bold text-success mb-0 mt-1">₹<%= String.format("%.2f", totalRevenue) %></h4>
                        </div>
                        <div class="stat-icon bg-success-subtle text-success">
                            💰
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Orders Card -->
            <div class="col-sm-6 col-xl-3">
                <div class="card stat-card border-0 shadow-sm p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted fw-semibold small d-block">TOTAL ORDERS</span>
                            <h4 class="fw-bold text-primary mb-0 mt-1"><%= totalOrders %></h4>
                        </div>
                        <div class="stat-icon bg-primary-subtle text-primary">
                            📦
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Users Card -->
            <div class="col-sm-6 col-xl-3">
                <div class="card stat-card border-0 shadow-sm p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted fw-semibold small d-block">ACTIVE CUSTOMERS</span>
                            <h4 class="fw-bold text-dark mb-0 mt-1"><%= totalUsers %></h4>
                        </div>
                        <div class="stat-icon bg-info-subtle text-info">
                            👥
                        </div>
                    </div>
                </div>
            </div>

            <!-- Low-Stock Alert Card -->
            <div class="col-sm-6 col-xl-3">
                <div class="card stat-card border-0 shadow-sm p-3 bg-white">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted fw-semibold small d-block">LOW STOCK ALERTS</span>
                            <h4 class="fw-bold <%= lowStockCount > 0 ? "text-danger" : "text-secondary" %> mb-0 mt-1">
                                <%= lowStockCount %> Items
                            </h4>
                        </div>
                        <div class="stat-icon <%= lowStockCount > 0 ? "bg-danger-subtle text-danger" : "bg-light text-muted" %>">
                            ⚠️
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- Section 2: Top Selling Products & Low Stock Alerts -->
        <div class="row g-4 mb-4">
            
            <!-- Top Selling Products -->
            <div class="col-lg-6">
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden h-100 bg-white">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-dark mb-0">🔥 Top-Selling Products</h5>
                        <small class="text-muted">By Order Frequency</small>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-3">Product Name</th>
                                        <th class="text-center">Units Sold</th>
                                        <th class="text-end pe-3">Revenue</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        if (topSellingList != null && !topSellingList.isEmpty()) { 
                                            for (Map<String, Object> item : topSellingList) {
                                    %>
                                    <tr>
                                        <td class="ps-3 fw-semibold text-dark"><%= item.get("name") %></td>
                                        <td class="text-center">
                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">
                                                <%= item.get("sold") %> orders
                                            </span>
                                        </td>
                                        <td class="text-end pe-3 fw-bold text-success">
                                            ₹<%= String.format("%.2f", (Double) item.get("sales")) %>
                                        </td>
                                    </tr>
                                    <% 
                                            }
                                        } else { 
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center py-4 text-muted">No sales recorded yet.</td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Low-Stock Warning List -->
            <div class="col-lg-6">
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden h-100 bg-white">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-danger mb-0">⚠️ Low Inventory Alerts (≤ 5 Units)</h5>
                        <a href="adminProducts.jsp" class="btn btn-outline-danger btn-sm fw-bold">Manage Inventory</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-3">Product</th>
                                        <th>Category</th>
                                        <th class="text-center pe-3">Remaining Stock</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        if (lowStockList != null && !lowStockList.isEmpty()) { 
                                            for (Product p : lowStockList) {
                                                boolean isCritical = (p.getStock() <= 0);
                                    %>
                                    <tr>
                                        <td class="ps-3 fw-semibold text-dark"><%= p.getName() %></td>
                                        <td><span class="badge bg-secondary"><%= p.getCategory() %></span></td>
                                        <td class="text-center pe-3">
                                            <span class="badge <%= isCritical ? "bg-danger" : "bg-warning text-dark" %> px-2 py-1">
                                                <%= isCritical ? "Out of Stock (0)" : p.getStock() + " Units Left" %>
                                            </span>
                                        </td>
                                    </tr>
                                    <% 
                                            }
                                        } else { 
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center py-4 text-success fw-semibold">
                                            ✅ All warehouse inventory levels are healthy!
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- Section 3: Recent Orders Table -->
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden bg-white">
            <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                <h5 class="fw-bold text-dark mb-0">📦 Recent Customer Orders</h5>
                <a href="adminOrders.jsp" class="btn btn-outline-primary btn-sm fw-bold">View All Orders</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th class="ps-3">Order ID</th>
                                <th>Customer Name</th>
                                <th>Product Item</th>
                                <th class="text-center">Paid Amount</th>
                                <th class="text-center">Payment Mode</th>
                                <th class="text-center pe-3">Current Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                if (recentOrders != null && !recentOrders.isEmpty()) { 
                                    for (Order o : recentOrders) {
                                        String st = (o.getStatus() != null) ? o.getStatus() : "Placed";
                                        String badge = "bg-secondary";
                                        if ("Placed".equalsIgnoreCase(st) || "Pending".equalsIgnoreCase(st)) badge = "bg-warning text-dark";
                                        else if ("Shipped".equalsIgnoreCase(st)) badge = "bg-primary";
                                        else if ("Delivered".equalsIgnoreCase(st)) badge = "bg-success";
                                        else if ("Cancelled".equalsIgnoreCase(st)) badge = "bg-danger";
                            %>
                            <tr>
                                <td class="ps-3 fw-bold text-primary">#ORD-<%= o.getOrderId() %></td>
                                <td class="fw-semibold"><%= o.getCustomerName() %></td>
                                <td><%= o.getProductName() %></td>
                                <td class="text-center fw-bold text-success">₹<%= String.format("%.2f", o.getTotalAmount()) %></td>
                                <td class="text-center"><span class="badge bg-light text-dark border"><%= o.getPaymentType() %></span></td>
                                <td class="text-center pe-3"><span class="badge <%= badge %> px-3 py-1"><%= st %></span></td>
                            </tr>
                            <% 
                                    }
                                } else { 
                            %>
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">No orders found yet.</td>
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