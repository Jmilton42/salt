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
$password = "machine-PLACE-4!"; // Default password from setup

// Connect to PostgreSQL
$conn_string = "host=$host port=$port dbname=$dbname user=$user password=$password";
$conn = pg_connect($conn_string);

if (!$conn) {
    die("Connection failed: " . pg_last_error());
}

// Search functionality (VULNERABLE)
$search = isset($_GET['search']) ? $_GET['search'] : '';
$results = [];

if ($search) {
    // VULNERABLE: Direct concatenation of user input
    $query = "SELECT * FROM products WHERE name LIKE '%$search%'";
    $result = pg_query($conn, $query);
    
    if ($result) {
        $results = pg_fetch_all($result);
    }
} else {
    // Default: show all products
    $query = "SELECT * FROM products";
    $result = pg_query($conn, $query);
    
    if ($result) {
        $results = pg_fetch_all($result);
    }
}

if (!$results) {
    $results = [];
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ghost Energy Stock</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <div class="container">
        <header>
            <h1>Ghost Energy Stock</h1>
            <nav>
                <a href="index.php">Home</a>
                <a href="admin.php">Manage</a>
            </nav>
        </header>

        <div class="search-bar">
            <form method="GET" action="index.php">
                <input type="text" name="search" placeholder="Search flavors..."
                    value="<?php echo htmlspecialchars($search); ?>">
                <button type="submit">Search</button>
            </form>
        </div>

        <div class="product-grid">
            <?php foreach ($results as $product): ?>
                <div class="product-card">
                    <div class="product-image">
                        <img src="<?php echo htmlspecialchars($product['image_url']); ?>"
                            alt="<?php echo htmlspecialchars($product['name']); ?>">
                    </div>
                    <div class="product-info">
                        <h3><?php echo htmlspecialchars($product['name']); ?></h3>
                        <p class="stock"><?php echo htmlspecialchars($product['stock']); ?> cans</p>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <?php if (empty($results) && $search): ?>
            <div class="no-results">
                <p>No products found for "<?php echo htmlspecialchars($search); ?>"</p>
            </div>
        <?php endif; ?>
    </div>
</body>

</html>
