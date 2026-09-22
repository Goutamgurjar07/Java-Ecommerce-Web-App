<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Registration - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow-lg border-0 rounded-3">
                    <div class="card-header bg-primary text-white text-center py-3">
                        <h4 class="mb-0 fw-bold">Create an Account</h4>
                    </div>
                    <div class="card-body p-4">

                        <%-- Alert Messages (Success / Error) --%>
                        <% 
                            String errorMsg = (String) session.getAttribute("failedMsg");
                            String succMsg = (String) session.getAttribute("succMsg");
                            if (errorMsg != null) { 
                        %>
                            <div class="alert alert-danger text-center" role="alert"><%= errorMsg %></div>
                        <% 
                                session.removeAttribute("failedMsg");
                            } 
                            if (succMsg != null) { 
                        %>
                            <div class="alert alert-success text-center" role="alert"><%= succMsg %></div>
                        <% 
                                session.removeAttribute("succMsg");
                            } 
                        %>

                        <!-- Registration Form -->
                        <form action="RegisterServlet" method="post">
                            <div class="mb-3">
                                <label for="name" class="form-label font-weight-bold">Full Name</label>
                                <input type="text" class="form-control" id="name" name="name" placeholder="Enter your full name" required>
                            </div>

                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address</label>
                                <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" required>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password" placeholder="Create a strong password" required>
                            </div>

                            <div class="mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phone" name="phone" placeholder="10-digit phone number" required>
                            </div>

                            <div class="mb-3">
                                <label for="address" class="form-label">Shipping Address</label>
                                <textarea class="form-control" id="address" name="address" rows="2" placeholder="Enter city, state, pin code" required></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 py-2 mt-2 fw-bold">Register Now</button>
                        </form>

                    </div>
                    <div class="card-footer text-center py-3 bg-white">
                        <small>Already have an account? <a href="login.jsp" class="text-decoration-none fw-bold">Login Here</a></small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>