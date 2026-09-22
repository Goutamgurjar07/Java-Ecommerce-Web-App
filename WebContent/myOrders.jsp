<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.dao.OrderDAO" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <%-- Session Guard --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            session.setAttribute("failedMsg", "Please login to view your orders!");
            response.sendRedirect("login.jsp");
            return;
        }

        CartDAO cartDao = new CartDAO();
        int cartCount = cartDao.getCartCountByUserId(user.getUserId());

        OrderDAO orderDao = new OrderDAO();
        List<Order> orderList = orderDao.getOrdersByUserId(user.getUserId());
    %>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4" href="index.jsp">🛒 E-Shop</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="index.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link active fw-bold" href="myOrders.jsp">📦 My Orders</a></li>
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
                            👤 Welcome, <%= user.getName() %>
                            <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                <span class="badge bg-danger ms-1">Admin</span>
                            <% } %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 rounded-3 mt-2">
                            <li><a class="dropdown-item fw-semibold py-2" href="profile.jsp">👤 My Profile & Security</a></li>
                            <li><a class="dropdown-item fw-semibold py-2" href="myOrders.jsp">📦 My Orders</a></li>
                            <li><a class="dropdown-item fw-semibold py-2" href="cart.jsp">🛒 View Cart (<%= cartCount %>)</a></li>
                            <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item fw-semibold text-warning py-2" href="adminDashboard.jsp">⚙️ Admin Dashboard</a></li>
                            <% } %>
                            <li><hr class="dropdown-divider"></li>
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

    <!-- Main Content: Orders History -->
    <div class="container my-4 mb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-primary mb-0">📦 Your Order History</h3>
            <a href="index.jsp" class="btn btn-outline-primary fw-bold">🛍️ Continue Shopping</a>
        </div>

        <% if (orderList != null && !orderList.isEmpty()) { %>
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th class="ps-4">Order ID</th>
                                <th>Product Details</th>
                                <th class="text-center">Total Paid</th>
                                <th class="text-center">Payment Mode</th>
                                <th class="text-center">Order Status</th>
                                <th class="text-center pe-4" style="min-width: 230px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                for (Order o : orderList) { 
                                    String rawStatus = o.getStatus();
                                    String status = (rawStatus != null && !rawStatus.trim().isEmpty()) ? rawStatus.trim() : "Placed";
                                    boolean isCancellable = "Placed".equalsIgnoreCase(status) || "Pending".equalsIgnoreCase(status) || "Received".equalsIgnoreCase(status);
                                    boolean isDelivered = "Delivered".equalsIgnoreCase(status);

                                    String badgeClass = "bg-secondary";
                                    if ("Placed".equalsIgnoreCase(status) || "Pending".equalsIgnoreCase(status) || "Received".equalsIgnoreCase(status)) {
                                        badgeClass = "bg-warning text-dark";
                                    } else if ("Processing".equalsIgnoreCase(status)) {
                                        badgeClass = "bg-info text-dark";
                                    } else if ("Shipped".equalsIgnoreCase(status)) {
                                        badgeClass = "bg-primary";
                                    } else if ("Delivered".equalsIgnoreCase(status)) {
                                        badgeClass = "bg-success";
                                    } else if ("Cancelled".equalsIgnoreCase(status)) {
                                        badgeClass = "bg-danger";
                                    }

                                    double origPrice = o.getPrice() > 0 ? o.getPrice() : o.getTotalAmount();
                                    double finalPaid = o.getTotalAmount();
                                    boolean hasDiscount = (origPrice > finalPaid);
                                    String pName = (o.getProductName() != null && !o.getProductName().trim().isEmpty()) ? o.getProductName() : "Product Item";
                            %>
                            <tr>
                                <td class="ps-4 fw-bold text-primary">#ORD-<%= o.getOrderId() %></td>
                                <td>
                                    <div class="fw-bold text-dark"><%= pName %></div>
                                    <small class="text-muted"><%= o.getOrderDate() != null ? o.getOrderDate() : "" %></small>
                                </td>
                                
                                <td class="text-center">
                                    <% if (hasDiscount) { %>
                                        <small class="text-muted text-decoration-line-through d-block">₹<%= String.format("%.2f", origPrice) %></small>
                                        <span class="fw-bold text-success fs-5">₹<%= String.format("%.2f", finalPaid) %></span>
                                    <% } else { %>
                                        <span class="fw-bold text-success fs-5">₹<%= String.format("%.2f", finalPaid) %></span>
                                    <% } %>
                                </td>

                                <td class="text-center">
                                    <span class="badge bg-secondary px-3 py-2"><%= o.getPaymentType() %></span>
                                </td>
                                <td class="text-center">
                                    <span class="badge <%= badgeClass %> px-3 py-2 fs-6"><%= status %></span>
                                </td>
                                <td class="text-center pe-4">
                                    <div class="d-flex justify-content-center align-items-center gap-2">
                                        <a href="orderInvoice.jsp?orderId=<%= o.getOrderId() %>" class="btn btn-outline-primary btn-sm fw-bold px-2">
                                            📄 Invoice
                                        </a>

                                        <% if (isDelivered) { %>
                                            <button type="button" class="btn btn-warning btn-sm fw-bold text-dark px-2 shadow-sm" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#reviewModal<%= o.getOrderId() %>">
                                                ⭐ Review
                                            </button>
                                        <% } else if (isCancellable) { %>
                                            <a href="CancelOrderServlet?orderId=<%= o.getOrderId() %>" 
                                               class="btn btn-danger btn-sm fw-bold px-2 shadow-sm"
                                               onclick="return confirm('Are you sure you want to cancel order #ORD-<%= o.getOrderId() %>?');">
                                                ❌ Cancel
                                            </a>
                                        <% } else { %>
                                            <button class="btn btn-outline-secondary btn-sm fw-semibold px-2" disabled>
                                                Locked
                                            </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Modals Placed Outside Table to Prevent HTML Hierarchy Break -->
        <% 
            for (Order o : orderList) { 
                if ("Delivered".equalsIgnoreCase(o.getStatus())) {
                    String pName = (o.getProductName() != null && !o.getProductName().trim().isEmpty()) ? o.getProductName() : "Product Item";
        %>
            <div class="modal fade" id="reviewModal<%= o.getOrderId() %>" tabindex="-1" aria-labelledby="modalLabel<%= o.getOrderId() %>" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content rounded-4 border-0 shadow">
                        <div class="modal-header bg-warning text-dark py-3">
                            <h5 class="modal-title fw-bold" id="modalLabel<%= o.getOrderId() %>">⭐ Rate & Review Product</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <form action="AddReviewServlet" method="post">
                            <div class="modal-body p-4 text-start">
                                <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                <input type="hidden" name="productName" value="<%= pName %>">

                                <h6 class="fw-bold text-dark mb-3">Item: <span class="text-primary"><%= pName %></span></h6>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Select Rating</label>
                                    <select name="rating" class="form-select form-select-lg fw-bold text-warning" required>
                                        <option value="5" selected>⭐⭐⭐⭐⭐ (5 - Excellent)</option>
                                        <option value="4">⭐⭐⭐⭐ (4 - Very Good)</option>
                                        <option value="3">⭐⭐⭐ (3 - Good)</option>
                                        <option value="2">⭐⭐ (2 - Fair)</option>
                                        <option value="1">⭐ (1 - Poor)</option>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Your Feedback</label>
                                    <textarea name="reviewText" class="form-control" rows="3" placeholder="Write your experience with this product..." required></textarea>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary fw-bold" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-warning fw-bold px-4">Submit Review</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        <% 
                } 
            } 
        %>

        <% } else { %>
            <div class="card shadow-sm border-0 text-center py-5">
                <div class="card-body">
                    <h4 class="text-muted fw-bold mb-2">📦 No Orders Found!</h4>
                    <p class="text-muted mb-3">You haven't placed any orders yet.</p>
                    <a href="index.jsp" class="btn btn-primary fw-bold px-4">Explore Products</a>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>