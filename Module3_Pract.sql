create database quanlysanpham;
use quanlysanpham;
create table khachhang(
makh int primary key,
hoten nvarchar(45)
);
create table hang(
masp int primary key,
tensp nvarchar(45),
gia int
);
create table hoadon(
sohoadon int primary key,
makh int,
ngayxuat date,
trigia int,
foreign key (makh) references khachhang(makh)
);
create table chitiet(
sohoadon int,
masp int,
soluong int,
primary key (sohoadon,masp),
foreign key (sohoadon) references hoadon(sohoadon),
foreign key (masp) references hang(masp)
);
--  In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 19/6/2006 và ngày 20/6/2006.
select hoadon.sohoadon, sum(hang.gia * chitiet.soluong) as trigia 
from hoadon join hang join chitiet on chitiet.sohoadon = hoadon.sohoadon and
hang.masp = chitiet.masp
where ngayxuat between "2006-06-19" and "2006-06-20"
group by hoadon.sohoadon;

--  In ra các số hóa đơn, trị giá hóa đơn trong tháng 6/2007, sắp xếp theo ngày (tăng dần) và trị giácủa hóa đơn (giảm dần).
select hoadon.sohoadon, sum(hang.gia * chitiet.soluong) as trigia 
from hoadon join hang join chitiet on chitiet.sohoadon = hoadon.sohoadon and
hang.masp = chitiet.masp
where ngayxuat like "2007-06%"
group by hoadon.sohoadon
order by hoadon.sohoadon asc,trigia desc;

-- In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 19/06/2007.
select khachhang.* from khachhang join hoadon on khachhang.makh = hoadon.makh
where hoadon.ngayxuat like "2007-06-19";

-- In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” muatrong tháng 10/2006.
select hang.masp, hang.tensp from hang
join hoadon
join khachhang
join chitiet on
chitiet.sohoadon = hoadon.sohoadon and chitiet.masp = hang.masp and hoadon.makh = khachhang.makh
where khachhang.hoten like "Nguyễn Văn A";

-- Tìm các số hóa đơn đã mua sản phẩm “Máy giặt” hoặc “Tủ lạnh”.
select hoadon.sohoadon from hoadon
inner join hang
inner join chitiet
on chitiet.masp = hang.masp and hoadon.sohoadon = chitiet.sohoadon
where hang.masp = 1 or hang.masp = 2
group by hoadon.sohoadon
order by hoadon.sohoadon asc;

--  Tìm các số hóa đơn đã mua sản phẩm “Máy giặt” hoặc “Tủ lạnh”, mỗi sản phẩm muavới số lượng từ 10 đến 20
select hoadon.sohoadon from hoadon
inner join hang
inner join chitiet
on chitiet.masp = hang.masp and hoadon.sohoadon = chitiet.sohoadon
where (hang.masp = 1 or hang.masp = 2) and (chitiet.soluong between 10 and 20)
group by hoadon.sohoadon
order by hoadon.sohoadon asc;

-- Tìm các số hóa đơn mua cùng lúc 2 sản phẩm “Máy giặt” và “Tủ lạnh”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
select sohoadon from chitiet
inner join hang on chitiet.masp = hang.masp
where (tensp like"Máy giặt" or tensp like "Tủ lạnh") and (soluong between 10 and 20)
group by sohoadon
having count(sohoadon) >1;


select  idhoadon from hoadon_chitiet 
inner join sp on hoadon_chitiet.idsp=sp.id
where (ten like "may giat" or ten like "tu lanh") and (slsp>=5 and slsp<=10) group by idhoadon having count(idhoadon)=2;

-- In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
select masp,tensp from hang 
where not exists (select null from chitiet
where chitiet.masp = hang.masp);

-- In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
select masp,tensp from hang 
where not exists (select null from chitiet
join hoadon on chitiet.sohoadon = hoadon.sohoadon
where chitiet.masp = hang.masp
and ngayxuat like "2006%");

-- In ra danh sách các sản phẩm (MASP,TENSP) có giá >300 sản xuất bán được trong năm2006.
select hang.masp,tensp from hang join hoadon
join chitiet on hoadon.sohoadon = chitiet.sohoadon and hang.masp = chitiet.masp
where hoadon.ngayxuat like "2006%" and hang.gia >300
group by tensp;

-- Tìm số hóa đơn đã mua tất cả các sản phẩm có giá >200
select hoadon.sohoadon from hang join hoadon
join chitiet on hoadon.sohoadon = chitiet.sohoadon and hang.masp = chitiet.masp
where  hang.gia >200
group by hoadon.sohoadon
having count(hoadon.sohoadon) = (select count(masp) from hang where gia>200)
;
select * from hang join chitiet on chitiet.masp = hang.masp
join hoadon on hoadon.sohoadon = chitiet.sohoadon
where hoadon.sohoadon not in 
(select hoadon.sohoadon
from hang join chitiet on chitiet.masp = hang.masp
join hoadon on hoadon.sohoadon = chitiet.sohoadon
where gia<200);

-- Tìm số hóa đơn trong năm 2006 đã mua tất cả các sản phẩm có giá <300
select hoadon.sohoadon from hang join hoadon
join chitiet on hoadon.sohoadon = chitiet.sohoadon and hang.masp = chitiet.masp
where hoadon.ngayxuat like "2006%" and hang.gia <300
group by hoadon.sohoadon
order by hoadon.sohoadon asc;

-- In ra danh sách 3 khách hàng (MAKH, HOTEN) mua nhiều hàng nhất (tính theo số lượng)
select khachhang.*, sum(soluong) from khachhang
join hoadon on hoadon.makh = khachhang.makh
join chitiet on chitiet.sohoadon = hoadon.sohoadon
group by khachhang.makh
order by sum(soluong) desc
limit 3;

--  In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá caonhất.-- 
select * from hang
order by gia desc
limit 3;

select distinct hang.* from
(select gia from hang
order by gia desc
limit 3) as topgiahang
inner join hang on hang.gia = topgiahang.gia;

-- In ra danh sách các sản phẩm (MASP, TENSP) có tên bắt đầu bằng chữ M, có giá bằng1 trong 3 mức giá cao nhất (của tất cả các sản phẩm)
select distinct hang.* from
(select gia from hang
order by gia desc
limit 3) as topgiahang
join hang on hang.gia = topgiahang.gia
where tensp like "M%";


select tensp from hang 
where gia in (select * from (select distinct gia from hang as goods
order by gia desc limit 3) as gia);

-- Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006
select count(distinct tensp) as sp from hang join hoadon join chitiet on chitiet.sohoadon = hoadon.sohoadon and chitiet.masp = hang.masp
where hoadon.ngayxuat like "2006%";

--  Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
select max(trigia) from hoadon;

select min(trigia) from hoadon;

-- Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
select avg(trigia) as "doanh thu tb 2006" from hoadon
where hoadon.ngayxuat like "2006%";

-- Tính doanh thu bán hàng trong năm 2006
select sum(trigia) as "doanh thu 2006" from hoadon
where hoadon.ngayxuat like "2006%";

-- Tìm số hóa đơn có trị giá cao nhất trong năm 2006
select sohoadon from hoadon
where trigia in (select max(trigia) from hoadon)
and hoadon.ngayxuat like "2006%";

-- Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
select hoten,trigia from khachhang
join hoadon on hoadon.makh = khachhang.makh
where trigia in (select max(trigia) from hoadon)
and hoadon.ngayxuat like "2006%";

-- Tính tổng số sản phẩm giá <300.
select count(case when gia<300 then 1 else null end) as "tong san pham duoi gia 300" from hang;

-- Tính tổng số sản phẩm theo từng giá.-- 
select gia,count(gia) from hang
group by gia;

-- Tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm bắt đầu bằng chữ M.
select tensp,max(gia) from hang
where tensp like "M%";
select tensp,min(gia) from hang
where tensp like "M%";
select avg(gia) as "giá trung bình sp bắt đầu băng M" from hang
where tensp like "M%";

-- Tính doanh thu bán hàng mỗi ngày
select ngayxuat,sum(trigia) as doanhthu from hoadon
group by ngayxuat;

-- Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
select month(ngayxuat),sum(trigia) as doanhthu from hoadon
where ngayxuat like "2006-10%"
group by month(ngayxuat)
order by ngayxuat asc;

-- Tính doanh thu bán hàng của từng tháng trong năm 2006
select month(ngayxuat),sum(trigia) as doanhthu from hoadon
where year(ngayxuat) = 2006
group by month(ngayxuat)
order by ngayxuat asc;

-- Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
select sohoadon,count(masp) as soluongsp from chitiet
group by sohoadon
having count(masp) >= 4;

-- Tìm hóa đơn có mua 3 sản phẩm có giá <300 (3 sản phẩm khác nhau).
select sohoadon, count(chitiet.masp) from chitiet
join hang on hang.masp = chitiet.masp
where gia < 300
group by sohoadon
having count(chitiet.masp) = 3
;
-- Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
select khachhang.*, count(hoadon.sohoadon) as tonghoadon from khachhang
join hoadon on hoadon.makh = khachhang.makh
group by khachhang.makh
having count(hoadon.sohoadon) = (select max(sohoadon) from (select count(sohoadon) as sohoadon from hoadon
group by makh) as t);

-- Tháng mấy trong năm 2006, doanh số bán hàng cao nhất?
select month(ngayxuat),sum(trigia) as doanhthu from hoadon
where year(ngayxuat) = 2006
group by month(ngayxuat)
having sum(trigia) = (select max(trigia) from (select sum(trigia) as trigia from hoadon
where year(ngayxuat) = 2006
group by month(ngayxuat) ) as t);

-- Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
select hang.masp, tensp, min(soluong) from hang
join hoadon
join chitiet on chitiet.sohoadon = hoadon.sohoadon and chitiet.masp = hang.masp
where year(ngayxuat) =2006
group by hang.masp
having min(soluong) = (select min(soluong) from (select sum(soluong) as soluong from chitiet
group by masp) as t);

-- Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
select * from (select khachhang.*,sum(trigia) as trigia , count(sohoadon) as tonghoadon from khachhang
join hoadon on hoadon.makh = khachhang.makh
group by khachhang.makh
order by trigia desc
limit 10) as khachhang
having tonghoadon = (select max(sohoadon) from (select count(sohoadon) as sohoadon from hoadon
group by makh) as t);