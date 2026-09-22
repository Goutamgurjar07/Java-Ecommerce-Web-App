<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Product - Admin Panel</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
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
    %>

    <!-- ⚙️ Admin Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4 text-warning" href="adminDashboard.jsp">⚙️ Admin Panel</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="adminNavbar">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="index.jsp">🌐 Storefront</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="adminDashboard.jsp">📊 Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="adminProducts.jsp">📦 Manage Products</a></li>
                    <li class="nav-item"><a class="nav-link text-warning active fw-bold" href="addProduct.jsp">➕ Add Product</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="adminOrders.jsp">📋 Manage Orders & Status</a></li>
                </ul>
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item me-3 text-white fw-semibold">
                        👑 Admin: <span class="text-warning fw-bold"><%= user.getName() %></span>
                    </li>
                    <li class="nav-item"><a class="btn btn-danger fw-bold btn-sm" href="LogoutServlet">Logout</a></li>
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
        <% session.removeAttribute("failedMsg"); } 
           if (succMsg != null) { 
        %>
            <div class="alert alert-success alert-dismissible fade show text-center fw-bold" role="alert">
                ✅ <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% session.removeAttribute("succMsg"); } %>
    </div>

    <!-- Main Content: Add Product Form -->
    <div class="container my-4 mb-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow-sm border-0 rounded-4">
                    <div class="card-header bg-primary text-white py-3 rounded-top-4">
                        <h4 class="fw-bold mb-0 text-center">➕ Add New Product</h4>
                    </div>
                    <div class="card-body p-4">
                        <form action="AddProductServlet" method="post" enctype="multipart/form-data">
                            
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Product Name</label>
                                <input type="text" class="form-control" name="pname" placeholder="Enter product name" required>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category</label>
                                    <select class="form-select fw-semibold" name="category" required>
                                        <option value="" selected disabled>Select Category</option>
                                        <option value="Mobiles">📱 Mobiles</option>
                                        <option value="Electronics">💻 Electronics</option>
                                        <option value="Fashion">👕 Fashion</option>
                                        <option value="Books">📚 Books</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Price (₹)</label>
                                    <input type="number" step="0.01" class="form-control" name="price" placeholder="0.00" min="1" required>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Stock Quantity</label>
                                    <input type="number" class="form-control" name="stock" placeholder="Enter stock" min="0" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Product Image</label>
                                    <input type="file" class="form-control" name="pimg" accept="image/*" required>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-semibold">Description</label>
                                <textarea class="form-control" name="description" rows="4" placeholder="Enter detailed product description..." required></textarea>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary btn-lg fw-bold shadow-sm">
                                    💾 Save & Upload Product
                                </button>
                                <a href="adminProducts.jsp" class="btn btn-outline-secondary fw-bold">Cancel</a>
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