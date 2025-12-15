<?php
// Database connection parameters
$server_ip = $_SERVER['SERVER_ADDR'] ?? '127.0.0.1';

// Fallback to gethostbynamel if SERVER_ADDR is not set or is loopback
if ($server_ip === '127.0.0.1' || $server_ip === '::1') {
    $ips = gethostbynamel(gethostname());
    if ($ips) {
        foreach ($ips as $ip) {
            // Prefer 192.168.x.x addresses as per requirements
            if (strpos($ip, '192.168.') === 0) {
                $server_ip = $ip;
                break;
            }
            // Otherwise take any non-loopback IPv4
            if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4) && $ip !== '127.0.0.1') {
                $server_ip = $ip;
            }
        }
    }
}

$ip_parts = explode('.', $server_ip);
$third_octet = isset($ip_parts[2]) ? $ip_parts[2] : '0';
$host = "192.168." . $third_octet . ".86";
$port = "5432";
$dbname = "energy_stock";
$user = "postgres";
$password = "machine-PLACE-4!";

// Connect to PostgreSQL
$conn_string = "host=$host port=$port dbname=$dbname user=$user password=$password";
$conn = pg_connect($conn_string);

if (!$conn) {
    die("Connection failed: " . pg_last_error());
}

$message = '';

// Handle Add Product
if (isset($_POST['add_product'])) {
    $name = $_POST['name'];
    $stock = $_POST['stock'];
    $image_url = $_POST['image_url'];

    // VULNERABLE: Direct concatenation
    $query = "INSERT INTO products (name, stock, image_url) VALUES ('$name', $stock, '$image_url')";
    $result = pg_query($conn, $query);

    if ($result) {
        $message = "Product added successfully!";
    } else {
        $message = "Error adding product: " . pg_last_error($conn);
    }
}

// Handle Update Stock
if (isset($_POST['update_stock'])) {
    $id = $_POST['id'];
    $stock = $_POST['stock'];

    // VULNERABLE: Direct concatenation
    $query = "UPDATE products SET stock = $stock WHERE id = $id";
    $result = pg_query($conn, $query);

    if ($result) {
        $message = "Stock updated successfully!";
    } else {
        $message = "Error updating stock: " . pg_last_error($conn);
    }
}

// Handle Delete Product
if (isset($_GET['delete'])) {
    $id = $_GET['delete'];

    // VULNERABLE: Direct concatenation
    $query = "DELETE FROM products WHERE id = $id";
    $result = pg_query($conn, $query);

    if ($result) {
        $message = "Product deleted successfully!";
    } else {
        $message = "Error deleting product: " . pg_last_error($conn);
    }
}

// Fetch all products
$query = "SELECT * FROM products ORDER BY id ASC";
$result = pg_query($conn, $query);
$products = [];
if ($result) {
    $products = pg_fetch_all($result);
}
if (!$products) {
    $products = [];
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Stock - Ghost Energy</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <div class="container">
        <header>
            <h1>Manage Stock</h1>
            <nav>
                <a href="index.php">Back to Home</a>
            </nav>
        </header>

        <?php if ($message): ?>
            <div class="message">
                <?php echo htmlspecialchars($message); ?>
            </div>
        <?php endif; ?>

        <div class="admin-section">
            <h2>Add New Product</h2>
            <form method="POST" action="admin.php" class="admin-form">
                <input type="text" name="name" placeholder="Product Name" required>
                <input type="number" name="stock" placeholder="Stock Quantity" required>
                <input type="text" name="image_url" placeholder="Image URL" required>
                <button type="submit" name="add_product">Add Product</button>
            </form>
        </div>

        <div class="admin-section">
            <h2>Current Inventory</h2>
            <table class="inventory-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Stock</th>
                        <th>Image URL</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($products as $product): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($product['id']); ?></td>
                            <td><?php echo htmlspecialchars($product['name']); ?></td>
                            <td>
                                <form method="POST" action="admin.php" style="display: inline;">
                                    <input type="hidden" name="id" value="<?php echo htmlspecialchars($product['id']); ?>">
                                    <input type="number" name="stock"
                                        value="<?php echo htmlspecialchars($product['stock']); ?>" style="width: 80px;">
                                    <button type="submit" name="update_stock" class="btn-small">Update</button>
                                </form>
                            </td>
                            <td><?php echo htmlspecialchars($product['image_url']); ?></td>
                            <td>
                                <a href="admin.php?delete=<?php echo htmlspecialchars($product['id']); ?>"
                                    onclick="return confirm('Delete this product?')" class="btn-delete">Delete</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>

</html>
