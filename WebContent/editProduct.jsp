<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - Admin Panel</title>
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

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            idParam = request.getParameter("pid");
        }

        int pid = 0;
        Product p = null;

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                pid = Integer.parseInt(idParam.trim());
                ProductDAO dao = new ProductDAO();
                p = dao.getProductById(pid);
            } catch (Exception e) {
                p = null;
            }
        }

        if (p == null) {
            session.setAttribute("failedMsg", "Invalid Product ID or Product not found!");
            response.sendRedirect("adminProducts.jsp");
            return;
        }

        String currentImg = (p.getImageName() != null && !p.getImageName().trim().isEmpty()) ? p.getImageName().trim() : "default.png";
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
                    <li class="nav-item"><a class="nav-link text-warning active fw-bold" href="adminProducts.jsp">📦 Manage Products</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="addProduct.jsp">➕ Add Product</a></li>
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

    <!-- Main Content: Edit Product Form -->
    <div class="container my-4 mb-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow-sm border-0 rounded-4">
                    <div class="card-header bg-warning text-dark py-3 rounded-top-4">
                        <h4 class="fw-bold mb-0 text-center">✏️ Edit Product Details</h4>
                    </div>
                    <div class="card-body p-4">
                        <form action="EditProductServlet" method="post" enctype="multipart/form-data">
                            
                            <input type="hidden" name="id" value="<%= p.getProductId() %>">

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Product Name</label>
                                <input type="text" class="form-control" name="pname" value="<%= p.getName() %>" required>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Category</label>
                                    <select class="form-select fw-semibold" name="category" required>
                                        <option value="Mobiles" <%= "Mobiles".equalsIgnoreCase(p.getCategory()) ? "selected" : "" %>>📱 Mobiles</option>
                                        <option value="Electronics" <%= "Electronics".equalsIgnoreCase(p.getCategory()) ? "selected" : "" %>>💻 Electronics</option>
                                        <option value="Fashion" <%= "Fashion".equalsIgnoreCase(p.getCategory()) ? "selected" : "" %>>👕 Fashion</option>
                                        <option value="Books" <%= "Books".equalsIgnoreCase(p.getCategory()) ? "selected" : "" %>>📚 Books</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Price (₹)</label>
                                    <input type="number" step="0.01" class="form-control" name="price" value="<%= p.getPrice() %>" required>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Stock Quantity</label>
                                    <input type="number" class="form-control" name="stock" value="<%= p.getStock() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Update Image (Optional)</label>
                                    <input type="file" class="form-control" name="pimg" accept="image/*">
                                    <small class="text-muted">Leave empty to keep existing image</small>
                                </div>
                            </div>

                            <div class="mb-3 text-center bg-light p-2 rounded border">
                                <small class="text-muted d-block mb-1">Current Image:</small>
                                <img src="uploads/<%= currentImg %>" alt="<%= p.getName() %>" style="height: 80px; object-fit: contain;" onerror="this.onerror=null; this.src='img/<%= currentImg %>'; this.onerror=function(){this.src='https://via.placeholder.com/80?text=No+Img';};">
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-semibold">Description</label>
                                <textarea class="form-control" name="description" rows="4" required><%= p.getDescription() %></textarea>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-warning btn-lg fw-bold shadow-sm">
                                    💾 Update Product Changes
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