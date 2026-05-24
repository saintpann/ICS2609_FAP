<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Exception</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { 
            font-family: 'Plus Jakarta Sans', sans-serif; 
            background-color: #f8f9fa; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            min-height: 100vh; 
            margin: 0;
        }
        .error-card { 
            background: white; 
            padding: 3.5rem 3rem; 
            border-radius: 24px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.02); 
            text-align: center; 
            max-width: 440px; 
        }
        .icon-box {
            font-size: 3.5rem;
            color: #64748b;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <div class="error-card">
        <div class="icon-box">
            <i class="bi bi-shield-exclamation-fill"></i>
        </div>
        <h1 class="fw-bold text-dark m-0">Error</h1>
        <h4 class="fw-bold text-secondary mb-3 fs-5">Execution Aborted</h4>
        <p class="text-muted small mb-4">An unexpected validation conflict broke the ongoing operation profile task routine. Please check your data fields.</p>
        <a href="login.jsp" class="btn btn-secondary w-100 py-2.5 rounded-3 fw-bold shadow-sm">
            Back to Safety
        </a>
    </div>
</body>
</html>