<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>404 - Page Not Found</title>
    <style>
        body { font-family: sans-serif; text-align: center; padding-top: 100px; }
        h1 { color: #dc3545; }
    </style>
</head>
<body>
    <h1>404: Page Not Found</h1>
    <p>The page you are looking for does not exist or has been moved.</p>
    <a href="${pageContext.request.contextPath}/login">Return to Login</a>
</body>
</html>