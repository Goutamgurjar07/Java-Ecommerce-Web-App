<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Products - Admin Panel</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .product-thumb {
            width: 55px;
            height: 55px;
            object-fit: contain;
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 4px;
            border: 1px solid #dee2e6;
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

        ProductDAO dao = new ProductDAO();
        List<Product> list = dao.getAllProducts();
        int totalProducts = (list != null) ? list.size() : 0;
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
                        <a class="nav-link text-white fw-bold" href="adminDashboard.jsp">📊 Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-warning active fw-bold" href="adminProducts.jsp">📦 Manage Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold" href="addProduct.jsp">➕ Add Product</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white fw-bold" href="adminOrders.jsp">📋 Manage Orders & Status</a>
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

    <!-- Main Content: Products Table -->
    <div class="container my-4 mb-5">
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
            
            <div class="card-header bg-white py-3 border-bottom d-flex flex-wrap justify-content-between align-items-center gap-2">
                <div>
                    <h3 class="fw-bold text-dark mb-0">📦 Store Inventory & Products</h3>
                    <small class="text-muted">Total Products: <span class="badge bg-primary"><%= totalProducts %></span></small>
                </div>
                <div class="d-flex gap-2">
                    <input type="text" id="adminSearchInput" onkeyup="filterAdminTable()" class="form-control form-control-sm" placeholder="🔍 Filter by name/category..." style="width: 220px;">
                    <a href="addProduct.jsp" class="btn btn-primary btn-sm fw-bold px-3">➕ Add New Product</a>
                </div>
            </div>

            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="productsTable">
                        <thead class="table-dark">
                            <tr>
                                <th class="ps-4">ID</th>
                                <th>Image</th>
                                <th>Product Name</th>
                                <th>Category</th>
                                <th>Price (₹)</th>
                                <th>Stock Status</th>
                                <th class="text-center pe-4" style="min-width: 180px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (list != null && !list.isEmpty()) {
                                    for (Product p : list) {
                                        String img = (p.getImageName() != null && !p.getImageName().trim().isEmpty()) ? p.getImageName().trim() : "default.png";
                                        boolean isOutOfStock = (p.getStock() <= 0);
                                        String pName = (p.getName() != null) ? p.getName() : "Product";
                            %>
                            <tr>
                                <td class="ps-4 fw-bold text-muted">#<%= p.getProductId() %></td>
                                <td>
                                    <!-- Clean Image Fallback -->
                                    <img src="uploads/<%= img %>" 
                                         alt="<%= pName %>" 
                                         class="product-thumb"
                                         onerror="this.onerror=null; this.src='https://via.placeholder.com/55?text=No+Img';">
                                </td>
                                <td>
                                    <div class="fw-bold text-dark"><%= pName %></div>
                                    <small class="text-muted" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden;">
                                        <%= p.getDescription() != null ? p.getDescription() : "" %>
                                    </small>
                                </td>
                                <td><span class="badge bg-info text-dark"><%= p.getCategory() != null ? p.getCategory() : "General" %></span></td>
                                <td class="fw-bold text-success fs-6">₹<%= String.format("%.2f", p.getPrice()) %></td>
                                <td>
                                    <span class="badge <%= isOutOfStock ? "bg-danger" : "bg-success" %> px-2 py-1">
                                        <%= isOutOfStock ? "Out of Stock (0)" : p.getStock() + " In Stock" %>
                                    </span>
                                </td>
                                <td class="text-center pe-4">
                                    <div class="d-flex justify-content-center align-items-center gap-2">
                                        <a href="editProduct.jsp?id=<%= p.getProductId() %>" class="btn btn-warning btn-sm fw-bold px-3 shadow-sm">
                                            ✏️ Edit
                                        </a>
                                        <a href="DeleteProductServlet?id=<%= p.getProductId() %>" 
                                           class="btn btn-danger btn-sm fw-bold px-2 shadow-sm" 
                                           onclick="return confirm('Are you sure you want to permanently delete this product?');">
                                            🗑️ Delete
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% 
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted fw-bold">
                                    <h4>📦 No products available in the inventory!</h4>
                                    <p class="text-muted">Click "Add New Product" above to list items in your store.</p>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <!-- Quick Live Filter Script -->
    <script>
        function filterAdminTable() {
            let input = document.getElementById("adminSearchInput");
            let filter = input.value.toUpperCase();
            let table = document.getElementById("productsTable");
            let tr = table.getElementsByTagName("tr");

            for (let i = 1; i < tr.length; i++) {
                let tdName = tr[i].getElementsByTagName("td")[2];
                let tdCat = tr[i].getElementsByTagName("td")[3];
                if (tdName || tdCat) {
                    let txtValueName = tdName ? (tdName.textContent || tdName.innerText) : "";
                    let txtValueCat = tdCat ? (tdCat.textContent || tdCat.innerText) : "";
                    if (txtValueName.toUpperCase().indexOf(filter) > -1 || txtValueCat.toUpperCase().indexOf(filter) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }
            }
        }
    </script>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>