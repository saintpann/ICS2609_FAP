<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8f9fa;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            background: #ffffff;
        }
        .form-control:focus {
            border-color: #8B5CF6;
            box-shadow: 0 0 0 0.25rem rgba(139, 92, 246, 0.25);
        }
        .btn-primary {
            background-color: #8B5CF6;
            border-color: #8B5CF6;
            font-weight: 600;
            padding: 0.6rem 1.2rem;
            border-radius: 8px;
            transition: all 0.2s ease;
        }
        .btn-primary:hover {
            background-color: #7c3aed;
            border-color: #7c3aed;
        }
        .input-group-text {
            background-color: #f1f5f9;
            border-right: none;
        }
        .form-control {
            border-left: none;
        }
    </style>
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</head>
<body>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-sm-10 col-md-8 col-lg-5">
            <div class="card login-card p-4 p-md-5">
                
                <div class="text-center mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-light rounded-circle p-3 mb-3" style="width: 60px; height: 60px; color: #8B5CF6 !important;">
                        <i class="bi bi-shield-lock-fill fs-3"></i>
                    </div>
                    <h2 class="fw-bold text-dark m-0">Welcome Back</h2>
                    <p class="text-muted small mt-1">Please sign in to access your dashboard</p>
                </div>

                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-danger d-flex align-items-center" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <div><%= request.getAttribute("errorMessage") %></div>
                    </div>
                <% } %>

                <div class="alert alert-danger d-flex align-items-center d-none" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <div>Sample Error Message Here</div>
                    </div>

                <form id="loginForm" action="LoginServlet" method="POST" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label for="username" class="form-label fw-semibold text-secondary small">Username</label>
                        <div class="input-group">
                            <span class="input-group-text text-muted" id="username-addon"><i class="bi bi-person"></i></span>
                            <input type="text" id="username" name="username" class="form-control" placeholder="Enter your username" required>
                            <div class="invalid-feedback">Username is required.</div>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="password" class="form-label fw-semibold text-secondary small">Password</label>
                        <div class="input-group">
                            <span class="input-group-text text-muted" id="password-addon"><i class="bi bi-key"></i></span>
                            <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                            <div class="invalid-feedback">Password is required.</div>
                        </div>
                    </div>

                    <div class="mb-4 d-flex justify-content-center">
                        <div class="g-recaptcha" data-sitekey="YOUR_RECAPTCHA_SITE_KEY_HERE" data-callback="recaptchaCallback"></div>
                    </div>
                    <div id="captcha-error" class="text-danger small text-center mb-3 d-none">
                        Please verify that you are not a robot.
                    </div>

                    <button type="submit" class="btn btn-primary w-100 text-white shadow-sm">
                        Sign In <i class="bi bi-arrow-right ms-2"></i>
                    </button>
                </form>
                
            </div>
        </div>
    </div>
</div>

<script>
    let isCaptchaValidated = false;
    function recaptchaCallback() {
        isCaptchaValidated = true;
        document.getElementById('captcha-error').classList.add('d-none');
    }

    document.getElementById('loginForm').addEventListener('submit', function (event) {
        const form = this;
        const captchaError = document.getElementById('captcha-error');

        if (!form.checkValidity() || !isCaptchaValidated) {
            event.preventDefault();
            event.stopPropagation();

            if (!isCaptchaValidated) {
                captchaError.classList.remove('d-none');
            }
        }
        form.classList.add('was-validated');
    }, false);
</script>
</body>
</html>