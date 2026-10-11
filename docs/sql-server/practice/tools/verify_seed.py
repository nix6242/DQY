"""Đọc INSERT VALUES cố định của kit để tính KPI/CSV, không chạy SQL Server."""
from pathlib import Path
from decimal import Decimal
from collections import Counter, defaultdict
import csv, json, re

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / '03-seed.sql').read_text(encoding='utf-8')

def table(name, identity=None):
    match = re.search(r'INSERT dbo\.' + name + r'\s*\(([^)]+)\) VALUES\s*(.*?);', source, re.S)
    if not match:
        raise ValueError('Missing seed INSERT: '+name)
    columns = [x.strip() for x in match[1].split(',')]
    rows = []
    for index, literal in enumerate(re.findall(r'\(([^)]*)\)', match[2]), 1):
        tokens = re.findall(r"N?'(?:[^']|'')*'|NULL|-?\d+(?:\.\d+)?", literal)
        assert len(tokens) == len(columns), (name, literal)
        values = []
        for token in tokens:
            if token == 'NULL': value = None
            elif token.startswith(("'", "N'")):
                value = token[token.index("'")+1:-1].replace("''", "'")
            else: value = Decimal(token)
            values.append(value)
        row = dict(zip(columns, values))
        if identity: row = {identity:index, **row}
        rows.append(row)
    return rows

customers = table('Customers','CustomerID')
products = table('Products','ProductID')
orders = table('Orders','OrderID')
items = table('OrderItems')
customer_ids={x['CustomerID'] for x in customers}
product_ids={x['ProductID'] for x in products}
order_map={x['OrderID']:x for x in orders}
assert len({x['Email'] for x in customers}) == 6
assert all(x['Price']>=0 and x['Stock']>=0 for x in products)
assert all(x['CustomerID'] in customer_ids for x in orders)
assert all(x['Status'] in ('Paid','Pending','Cancelled') for x in orders)
assert len({(x['OrderID'],x['ProductID']) for x in items}) == len(items)
assert all(x['OrderID'] in order_map and x['ProductID'] in product_ids and x['Quantity']>0 and x['UnitPrice']>=0 for x in items)
fact=[]
for item in items:
    order=order_map[item['OrderID']]
    if order['Status']=='Paid':
        fact.append({
            'OrderID':int(item['OrderID']),'ProductID':int(item['ProductID']),
            'CustomerID':order['CustomerID'],'OrderDate':order['OrderDate'][:10],
            'Quantity':int(item['Quantity']),'UnitPrice':item['UnitPrice'],
            'LineAmount':item['Quantity']*item['UnitPrice']})
revenue=sum(x['LineAmount'] for x in fact)
monthly=defaultdict(Decimal)
for row in fact:monthly[row['OrderDate'][:7]]+=row['LineAmount']
assert [len(customers),len(products),len(orders),len(items),len(fact)]==[6,6,8,13,11]
assert Counter(x['Status'] for x in orders)=={'Paid':6,'Pending':1,'Cancelled':1}
assert revenue==Decimal('57200000')
assert sum(x['Quantity']*x['UnitPrice'] for x in items)==Decimal('73600000')
assert len({x['OrderID'] for x in fact})==6
assert len({x['CustomerID'] for x in fact})==4
assert sum(x['Quantity'] for x in fact)==20
assert dict(monthly)=={'2025-01':Decimal('25300000'),'2025-02':Decimal('1600000'),'2025-03':Decimal('15000000'),'2025-04':Decimal('15300000')}
assert customer_ids-{x['CustomerID'] for x in orders}=={5,6}
assert product_ids-{int(x['ProductID']) for x in items}=={6}

def write_csv(filename, rows):
    path=ROOT/'powerbi-csv'/filename
    path.parent.mkdir(exist_ok=True)
    with path.open('w',encoding='utf-8-sig',newline='') as stream:
        writer=csv.DictWriter(stream,fieldnames=list(rows[0]));writer.writeheader()
        for row in rows:
            # Hai chữ số thập phân cho tiền, số nguyên cho IDs/Quantity/Stock.
            values={k:(format(v,'.2f') if k in ('Price','UnitPrice','LineAmount') else
                       str(int(v)) if isinstance(v,Decimal) else '' if v is None else v)
                    for k,v in row.items()}
            writer.writerow(values)
write_csv('Customers.csv',customers)
write_csv('Products.csv',products)
write_csv('FactPaidSales.csv',fact)
# Đọc lại CSV để bắt lỗi delimiter/encoding/export, không chỉ kiểm tra object trước ghi.
for filename,count in [('Customers.csv',6),('Products.csv',6),('FactPaidSales.csv',11)]:
    with (ROOT/'powerbi-csv'/filename).open(encoding='utf-8-sig',newline='') as stream:
        assert len(list(csv.DictReader(stream)))==count
with (ROOT/'powerbi-csv'/'FactPaidSales.csv').open(encoding='utf-8-sig',newline='') as stream:
    exported=list(csv.DictReader(stream))
assert sum(Decimal(x['LineAmount']) for x in exported)==Decimal('57200000.00')
assert len({x['OrderID'] for x in exported})==6
assert len({x['CustomerID'] for x in exported})==4
assert sum(int(x['Quantity']) for x in exported)==20
result={'Customers':6,'Products':6,'Orders':8,'OrderItems':13,'FactRows':11,
        'PaidOrders':6,'ActiveCustomers':4,'Units':20,'Revenue':'57200000.00',
        'AllStatusAmount':'73600000.00','AverageOrderValue':'9533333.33',
        'Monthly':{k:format(v,'.2f') for k,v in sorted(monthly.items())},
        'Method':'Independent Python calculation from SQL INSERT literals; NOT SQL Server execution'}
print(json.dumps(result,ensure_ascii=False,indent=2))
