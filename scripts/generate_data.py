import csv
import os
import random
from datetime import datetime, timedelta

# Set seed for reproducibility
random.seed(42)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DATA_DIR = os.path.join(BASE_DIR, "data", "raw")
os.makedirs(RAW_DATA_DIR, exist_ok=True)

# 1. MARKETS (10 markets in 4 zones)
markets = [
    {"market_code": "MKT_NA_E", "market_name": "North America East", "zone": "North America", "region": "US East"},
    {"market_code": "MKT_NA_W", "market_name": "North America West", "zone": "North America", "region": "US West"},
    {"market_code": "MKT_EU_C", "market_name": "Europe Central", "zone": "Europe", "region": "Germany/DACH"},
    {"market_code": "MKT_EU_UK", "market_name": "Europe UK & Ireland", "zone": "Europe", "region": "UK & IE"},
    {"market_code": "MKT_IN_N", "market_name": "India North", "zone": "Asia Pacific", "region": "India Del/NCR"},
    {"market_code": "MKT_IN_S", "market_name": "India South", "zone": "Asia Pacific", "region": "India BLR/CHE"},
    {"market_code": "MKT_APAC_SG", "market_name": "APAC Singapore & SEA", "zone": "Asia Pacific", "region": "Southeast Asia"},
    {"market_code": "MKT_APAC_JP", "market_name": "APAC Japan", "zone": "Asia Pacific", "region": "Japan"},
    {"market_code": "MKT_LATAM_BR", "market_name": "LATAM Brazil", "zone": "Latin America", "region": "Brazil"},
    {"market_code": "MKT_ME_DB", "market_name": "Middle East Dubai", "zone": "Middle East", "region": "UAE/GCC"}
]

with open(os.path.join(RAW_DATA_DIR, "markets.csv"), "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["market_code", "market_name", "zone", "region"])
    writer.writeheader()
    writer.writerows(markets)

print(f"Generated {len(markets)} markets.")

# 2. CUSTOMERS (150 customers)
customer_types = ["Brick & Mortar", "E-Commerce", "Wholesale Distributor", "Corporate Reseller"]
company_prefixes = ["Apex", "Nexus", "Vertex", "Quantum", "Synergy", "Starlight", "Vanguard", "Horizon", "Pinnacle", "Titan", "Omni", "Delta", "Beacon", "Crest", "Summit"]
company_suffixes = ["Tech", "Systems", "Solutions", "Retail", "Global", "Logistics", "Digital", "Direct", "Hub", "Networks", "Mart", "Enterprise", "Electronics"]

customers = []
for i in range(1, 151):
    c_code = f"CUST_{i:03d}"
    prefix = random.choice(company_prefixes)
    suffix = random.choice(company_suffixes)
    c_name = f"{prefix} {suffix} #{i}"
    c_type = random.choice(customer_types)
    mkt = random.choice(markets)["market_code"]
    customers.append({
        "customer_code": c_code,
        "customer_name": c_name,
        "customer_type": c_type,
        "market_code": mkt
    })

with open(os.path.join(RAW_DATA_DIR, "customers.csv"), "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["customer_code", "customer_name", "customer_type", "market_code"])
    writer.writeheader()
    writer.writerows(customers)

print(f"Generated {len(customers)} customers.")

# 3. PRODUCTS (50 products across 5 categories)
categories = {
    "Laptops & Desktops": [
        ("ProBook Ultrabook 14", 850.00, 1199.99),
        ("Workstation Tower ZX", 1400.00, 1999.99),
        ("Gaming Laptop Xtreme", 1200.00, 1749.99),
        ("SlimBook Air 13", 650.00, 949.99),
        ("Enterprise Desktop D5", 500.00, 729.99),
        ("Convertible 2-in-1 Touch", 750.00, 1099.99),
        ("Developer Studio Laptop", 1600.00, 2299.99),
        ("Budget Office PC", 320.00, 479.99),
        ("Mini Form Factor PC", 410.00, 599.99),
        ("Rugged Industrial Laptop", 1800.00, 2599.99)
    ],
    "Peripherals & Accessories": [
        ("Ergonomic Wireless Mouse", 22.00, 49.99),
        ("Mechanical RGB Keyboard", 45.00, 99.99),
        ("4K UHD 27-inch Monitor", 180.00, 349.99),
        ("Curved Ultrawide 34-inch Monitor", 320.00, 599.99),
        ("Noise-Canceling USB Headset", 35.00, 79.99),
        ("HD Pro Webcam 1080p", 28.00, 64.99),
        ("Thunderbolt 4 Docking Station", 90.00, 189.99),
        ("Dual Monitor Arm Stand", 30.00, 69.99),
        ("Wireless Presenter Remote", 12.00, 29.99),
        ("Desk Pad XL Felt", 8.00, 19.99)
    ],
    "Networking & Servers": [
        ("Enterprise Gigabit Router", 210.00, 420.00),
        ("Managed 24-Port PoE Switch", 280.00, 549.99),
        ("Wi-Fi 6E Mesh Access Point", 110.00, 229.99),
        ("Rackmount Server Node 1U", 2200.00, 3499.99),
        ("Hardware Firewall Appliance", 450.00, 899.99),
        ("10GbE Fiber Transceiver", 35.00, 85.00),
        ("Cat6A Ethernet Cable 100m", 25.00, 55.00),
        ("VPN Gateway Pro", 380.00, 749.99),
        ("Network Attached Storage 4-Bay", 300.00, 579.99),
        ("Uninterruptible Power Supply 1500VA", 140.00, 269.99)
    ],
    "Storage Solutions": [
        ("Internal NVMe SSD 2TB", 70.00, 139.99),
        ("External Portable SSD 1TB", 50.00, 99.99),
        ("Enterprise SAS Hard Drive 10TB", 160.00, 299.99),
        ("High-Speed SD Card 256GB", 18.00, 39.99),
        ("Internal SATA SSD 1TB", 40.00, 79.99),
        ("Encrypted USB Flash Drive 128GB", 22.00, 49.99),
        ("RAID Storage Expansion Array", 850.00, 1499.99),
        ("Surveillance Hard Drive 8TB", 130.00, 239.99),
        ("Cloud Backup Gateway Drive", 110.00, 219.99),
        ("Ultra-Fast PCIe Gen5 SSD 4TB", 190.00, 369.99)
    ],
    "Smart Office": [
        ("Smart Conference Speakerphone", 85.00, 179.99),
        ("Interactive Smart Whiteboard 65", 1500.00, 2799.99),
        ("Motorized Standing Desk", 260.00, 499.99),
        ("Smart Desk LED Light Bar", 25.00, 59.99),
        ("Biometric Door Access Scanner", 140.00, 289.99),
        ("Air Quality Monitor Office", 45.00, 99.99),
        ("Smart Power Strip Wi-Fi", 15.00, 34.99),
        ("Wireless Charging Station 3-in-1", 20.00, 44.99),
        ("Cable Management Tray Channel", 10.00, 24.99),
        ("Document Scanner High-Speed", 180.00, 349.99)
    ]
}

products = []
p_idx = 1
for cat_name, item_list in categories.items():
    for name, cost, price in item_list:
        p_code = f"PROD_{p_idx:03d}"
        sub_cat = cat_name.split()[0]
        products.append({
            "product_code": p_code,
            "product_name": name,
            "category": cat_name,
            "sub_category": sub_cat,
            "unit_cost": cost,
            "unit_price": price
        })
        p_idx += 1

with open(os.path.join(RAW_DATA_DIR, "products.csv"), "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["product_code", "product_name", "category", "sub_category", "unit_cost", "unit_price"])
    writer.writeheader()
    writer.writerows(products)

print(f"Generated {len(products)} products.")

# 4. TARGETS (Monthly target per market for 2023, 2024, 2025)
# 10 markets * 36 months = 360 target records
targets = []
# Give each market a baseline target per month with seasonal variance and growth
market_baselines = {
    "MKT_NA_E": 850000.00,
    "MKT_NA_W": 750000.00,
    "MKT_EU_C": 680000.00,
    "MKT_EU_UK": 550000.00,
    "MKT_IN_N": 480000.00,
    "MKT_IN_S": 520000.00,
    "MKT_APAC_SG": 420000.00,
    "MKT_APAC_JP": 600000.00,
    "MKT_LATAM_BR": 350000.00,
    "MKT_ME_DB": 390000.00
}

for year in [2023, 2024, 2025]:
    for month in range(1, 13):
        for mkt in markets:
            m_code = mkt["market_code"]
            base = market_baselines[m_code]
            # Add year growth factor (e.g., +8% per year)
            year_factor = 1.0 + (year - 2023) * 0.08
            # Add monthly seasonality (Q4 spike, Q1 dip)
            seasonal_map = {1: 0.88, 2: 0.90, 3: 0.98, 4: 0.95, 5: 1.00, 6: 1.02, 7: 0.94, 8: 0.96, 9: 1.05, 10: 1.10, 11: 1.18, 12: 1.25}
            season_factor = seasonal_map[month]
            # Small random variation
            random_noise = random.uniform(0.97, 1.03)
            
            target_amount = round(base * year_factor * season_factor * random_noise, 2)
            targets.append({
                "market_code": m_code,
                "target_year": year,
                "target_month": month,
                "target_sales": target_amount
            })

with open(os.path.join(RAW_DATA_DIR, "targets.csv"), "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["market_code", "target_year", "target_month", "target_sales"])
    writer.writeheader()
    writer.writerows(targets)

print(f"Generated {len(targets)} targets.")

# 5. SALES TRANSACTIONS (105,000 transactions)
NUM_TRANSACTIONS = 105000
start_date = datetime(2023, 1, 1)
end_date = datetime(2025, 12, 31)
total_days = (end_date - start_date).days + 1

sales_transactions = []

# Product lookup for cost/price
prod_map = {p["product_code"]: p for p in products}

# Market weightings (NA_E and NA_W generate more transactions)
market_weights = [0.18, 0.16, 0.14, 0.11, 0.10, 0.11, 0.07, 0.07, 0.03, 0.03]
market_codes = [m["market_code"] for m in markets]

# Customer lookup by market for realistic regional ordering
customers_by_market = {}
for c in customers:
    m = c["market_code"]
    if m not in customers_by_market:
        customers_by_market[m] = []
    customers_by_market[m].append(c["customer_code"])

print("Generating 105,000 sales transaction records...")

for i in range(1, NUM_TRANSACTIONS + 1):
    trx_id = f"TRX{i:07d}"
    
    # Random date with seasonal density (more orders in Nov/Dec)
    day_offset = random.randint(0, total_days - 1)
    tx_date = start_date + timedelta(days=day_offset)
    if tx_date.month in [11, 12] and random.random() < 0.25:
        # boost late Q4 transactions
        tx_date = tx_date.replace(day=random.randint(1, 28))
    
    date_str = tx_date.strftime("%Y-%m-%d")
    
    # Pick market based on weights
    mkt_code = random.choices(market_codes, weights=market_weights, k=1)[0]
    
    # Pick customer belonging to that market or global
    cust_code = random.choice(customers_by_market[mkt_code])
    
    # Pick product
    prod = random.choice(products)
    p_code = prod["product_code"]
    u_cost = prod["unit_cost"]
    u_price = prod["unit_price"]
    
    # Quantity: 1 to 20 for accessories, 1 to 5 for laptops/servers
    if prod["category"] in ["Peripherals & Accessories", "Storage Solutions"]:
        qty = random.choices(range(1, 25), weights=[15, 12, 10, 8, 7, 6, 5, 4, 3, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], k=1)[0]
    else:
        qty = random.choices([1, 2, 3, 4, 5, 8, 10], weights=[50, 25, 12, 6, 4, 2, 1], k=1)[0]
        
    # Discount: 0% to 15% (with higher probability of 0%)
    discount_pct = random.choices([0.0, 0.03, 0.05, 0.08, 0.10, 0.15], weights=[60, 15, 12, 7, 4, 2], k=1)[0]
    
    sales_amt = round(qty * u_price * (1.0 - discount_pct), 2)
    cost_amt = round(qty * u_cost, 2)
    profit_amt = round(sales_amt - cost_amt, 2)
    
    sales_transactions.append({
        "transaction_id": trx_id,
        "order_date": date_str,
        "customer_code": cust_code,
        "product_code": p_code,
        "market_code": mkt_code,
        "order_qty": qty,
        "unit_price": u_price,
        "unit_cost": u_cost,
        "discount_pct": discount_pct,
        "sales_amount": sales_amt,
        "cost_amount": cost_amt,
        "profit_amount": profit_amt
    })

with open(os.path.join(RAW_DATA_DIR, "sales_transactions.csv"), "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "transaction_id", "order_date", "customer_code", "product_code", "market_code",
        "order_qty", "unit_price", "unit_cost", "discount_pct", "sales_amount", "cost_amount", "profit_amount"
    ])
    writer.writeheader()
    writer.writerows(sales_transactions)

print(f"Successfully generated {len(sales_transactions)} sales transaction records in data/raw/sales_transactions.csv")
