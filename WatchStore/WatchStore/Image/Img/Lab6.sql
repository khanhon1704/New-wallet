--Câu 1
DECLARE c_DocThongTin CURSOR
SCROLL
FOR
	SELECT DG.ma_docgia, ho+' '+tenlot+' '+ten as HoTen, DK.isbn, TS.TuaSach, DK.ngaygio_dk
	FROM DocGia DG, DangKy DK, DauSach DS, TuaSach TS
	WHERE DG.ma_docgia = DK.ma_docgia
	AND DS.isbn = DK.isbn
	AND DS.ma_tuasach = TS.ma_tuasach

	-- m? con tr?
	OPEN c_DocThongTin 

	DECLARE @ma_docgia int, @hoten nvarchar(31), @isbn int, 
			@TuaSach nvarchar(63), @ngaygio_dk smalldatetime
	DECLARE @i int
	set @i=1
	--truy xu?t t?ng dòng trong con tr?
	FETCH NEXT FROM c_DocThongTin 
	into @ma_docgia, @hoten, @isbn, @TuaSach, @ngaygio_dk

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		FETCH NEXT FROM c_DocThongTin 
		into @ma_docgia, @hoten, @isbn, @TuaSach, @ngaygio_dk

		print CAST(@i AS nvarchar(10)+': Ma doc gia: '+CAST(@ma_docgia AS nvarchar(10))+
				'		Ho ten: '+@hoten+'		isbn: '+CAST(@isbn as nvarchar(15))+
				'		Tua sach: '+@TuaSach+'		ngay dang ky: '+CAST(@ngaygio_dk as nvarchar(15))
			
		set @i=@i+1
	END

	-- ?óng con tr? và xóa kh?i b? nh? 
	CLOSE c_DocThongTin 
	DEALLOCATE c_DocThongTin
	

--Câu 2. Gi? s? thêm vào b?ng DocGia thu?c tính LoaiDG. N?u ??c gi? là ng??i l?n 
--thì c?p nh?t giá tr? ‘ng??i l?n’ vào thu?c tính LoaiDG và ng??c l?i.

--thêm c?t ??c gi?
alter table DocGia 
	add LoaiDG nvarchar(15)

--T?o con tr? ch?a thông tin ng??i l?n
declare c_ThongTinNguoiLon cursor 
scroll
for
	select ma_docgia from NguoiLon

	open c_ThongTinNguoiLon
	declare @madocgianguoilon int

	fetch next from c_ThongTinNguoiLon into @madocgianguoilon
	while @@FETCH_STATUS = 0
	begin 
		fetch next from c_ThongTinNguoiLon into @madocgianguoilon
		update DocGia
		set LoaiDG = N'Ng??i l?n'
		where ma_docgia = @madocgianguoilon
	end
	close c_ThongTinNguoiLon
	DEALLOCATE c_ThongTinNguoiLon


	select * from DocGia
	select * from NguoiLon

--T?o con tr? ch?a thông tin TreEm
declare c_ThongTinTreEm cursor 
scroll
for
	select ma_docgia from TreEm

	open c_ThongTinTreEm
	declare @madocgiantreem int

	fetch next from c_ThongTinTreEm into @madocgiantreem
	while @@FETCH_STATUS = 0
	begin 
		fetch next from c_ThongTinTreEm into @madocgiantreem
		update DocGia
		set LoaiDG = N'Tr? em'
		where ma_docgia = @madocgiantreem
	end
	close c_ThongTinTreEm
	DEALLOCATE c_ThongTinTreEm


--function 
--Câu 1: Nh?p vào tháng n?m cho bi?t có bao nhiêu sách m??n
CREATE function f_SoSachDaMuon (@thang int, @nam int)
returns int as 
begin 
	declare @SoSachMuon int 
	set @SoSachMuon = (select count(isbn)
						from Muon 
						where Month(NgayGio_Muon) = @thang
						and Year(NgayGio_Muon) = @nam)
	return @SoSachMuon
end

select dbo.f_SoSachDaMuon (6, 2002)

--Câu 2:  Nh?p vào n?m cho bi?t có bao nhiêu ??c gi? m??n ít nh?t m?t cu?n sáchs
alter function f_SoLuongDocGia (@nam int)
returns int as 
begin 
	declare @SoLuongDocGia int, @SoLuongSachMuon int
	select @SoLuongSachMuon = count(ma_cuonsach)
	from Muon 
	where year(ngayGio_muon) = @nam
	if @SoLuongSachMuon >= 1
	begin 
		set @SoLuongDocGia =(select count(distinct(ma_docgia))
							from Muon
							where year(ngayGio_muon) = @nam)
	end
	return @SoLuongDocGia
end

select dbo.f_SoLuongDocGia(2002)

--Câu 3. Nh?p vào isbn cho bi?t th?i gian trung bình m??n sách là bao lâu.
create function f_ThoiGianTrungBinh(@isbn int)
returns smallint as 
begin 
	declare @ThoiGianMuonTrungBinh smallint
	set @ThoiGianMuonTrungBinh=(select avg(datediff(day,ngayGio_muon, ngayGio_tra))
								from QuaTrinhMuon
								where isbn = @isbn)
	return @ThoiGianMuonTrungBinh
end

select dbo.f_ThoiGianTrungBinh(14)

select isbn, datediff(day,ngayGio_muon, ngayGio_tra)
from QuaTrinhMuon

--Câu 4. Nh?p vào mã ??c gi? cho bi?t ??c gi? ?ó có m??n sách quá h?n bao nhiêu l?n.
alter function f_SachQuaHan(@ma_docgia smallint)
returns int as
begin
	declare @SoLanQuaHan int, @SoNgayQuaHan int
	set @SoLanQuaHan =(select count(datediff(day,ngay_hethan,ngayGio_tra))
						from QuaTrinhMuon
						where ma_docgia = @ma_docgia
						and datediff(day, ngayGio_muon,ngayGio_tra) > 14)
	return @SoLanQuaHan
end

select dbo.f_SachQuaHan(2)

--select ma_docgia, ma_cuonsach, count(datediff(day, ngayGio_muon,ngayGio_tra))
--from QuaTrinhMuon
--where datediff(day, ngayGio_muon,ngayGio_tra) > 14
--group by ma_docgia, ma_cuonsach

--Câu 5. Nh?p vào ??u sách cho bi?t ??u sách có hi?n ?ang còn bao nhiêu cu?n.
alter function f_SoLuongCuonSach(@isbn int)
returns int as 
begin
	declare @SoLuongCuonSach int
	set @SoLuongCuonSach = (select count(*)
						from DauSach DS, CuonSach CS 
						where DS.isbn=CS.isbn and CS.TinhTrang='Y'
						and DS.isbn = @isbn)
	return @SoLuongCuonSach
end
select dbo.f_SoLuongCuonSach(1)

select *
from DauSach DS, CuonSach CS 
where DS.isbn=CS.isbn and CS.TinhTrang='Y'


--Câu 6: Nh?p vào mã ??c gi? cho bi?t thông tin nh?ng sách mà ??c gi? ?ó ?ã t?ng m??n.
create function f_SachTungMuon (@ma_docgia int)
returns table
as
	return (select M.isbn, t.ma_tuasach, ngonngu, bia, trangthai, TuaSach, tacgia, tomtat
			from Muon M, DauSach D, TuaSach T
			where T.ma_tuasach=D.ma_tuasach
			and M.isbn = D.isbn
			--and m.ma_docgia = @ma_docgia
		union 
			select M.isbn, T.ma_tuasach, ngonngu, bia, trangthai, TuaSach, tacgia, tomtat
			from QuaTrinhMuon M, DauSach D, TuaSach T
			where T.ma_tuasach = D.ma_tuasach
			and M.isbn = D.isbn
			--and M.ma_docgia = @ma_docgia)
select * from f_SachTungMuon (5)

--Câu 7. Nh?p vào ??u sách cho bi?t thông tin v? ??u sách ?ó.
create function f_ThongTinDauSach (@ma_tuasach int)
RETURNS @BangDauSach table (isbn int, ma_tuasach int, ngonngu nvarchar(15),
							bia nvarchar(15), trangthai nvarchar(1))
as
begin 
	insert into @BangDauSach
		select isbn, ma_tuasach, ngonngu, bia, trangthai
		from DauSach 
		where ma_tuasach=@ma_tuasach
	return 
end 

select * from f_ThongTinDauSach(1)

use QLTV 
go

--Câu 8. Nh?p vào ??u sách cho bi?t ??u sách ?ó ?ã có bao nhiêu ng??i l?n và bao 
--nhiêu tr? em m??n.
alter function f_SoNguoiMuonSach (@ma_cuonsach int)
returns int as 
begin 
	declare @TongDocGia int
	declare @SoNguoiLonMuon int
	set @SoNguoiLonMuon=(select count(N.ma_docgia)
						from Muon M, NguoiLon N, DauSach D, TuaSach T
						where M.ma_docgia = N.ma_docgia
						and D.isbn = M.isbn
						and T.ma_tuasach = D.ma_tuasach
						and M.ma_cuonsach = @ma_cuonsach) 
	declare @SoTreEmMuon int
	set @SoTreEmMuon=(select count(TE.ma_docgia)
						from Muon M, TreEm TE, DauSach D, TuaSach T
						where M.ma_docgia = TE.ma_docgia
						and D.isbn = M.isbn
						and T.ma_tuasach = D.ma_tuasach
						and M.isbn = @ma_cuonsach) 
	set @TongDocGia = @SoNguoiLonMuon + @SoTreEmMuon
	return @TongDocGia
end

select dbo.f_SoNguoiMuonSach(3)


select * from Muon
select * from NguoiLon
select * from TreEm

select M.ma_cuonsach, T.ma_tuasach, M.ma_docgia, count(N.ma_docgia)
from Muon M, NguoiLon N, DauSach D, TuaSach T
where M.ma_docgia = N.ma_docgia
and T.ma_tuasach=3
and D.isbn = M.isbn
and T.ma_tuasach = D.ma_tuasach
 


--create function f_SL_DauSach_TE__NL_Muon (@ma_tuasach int)
--returns @SL_Muon table (sl_NL int, sl_TE int)
--as
--begin
--	insert into @SL_Muon
--		SELECT      
--			sum(count1.[COUNT]),
--            sum(count2.[COUNT2])
--			FROM
--			(
--				select NL.ma_docgia as nl2 ,count(m.ma_docgia) as COUNT
--				from NguoiLon nl, DauSach ds,TuaSach ts,Muon m
--				where m.ma_docgia = nl.ma_docgia and ds.isbn = m.isbn and ts.ma_tuasach = ds.ma_tuasach
--				and ds.ma_tuasach = @ma_tuasach
--				group by NL.ma_docgia
    
--			) count1
--			FULL OUTER JOIN
--			(
--				select te.ma_docgia as te2,count(m.ma_docgia) as COUNT2
--				from TreEm te, DauSach ds,TuaSach ts,Muon m 
--				where m.ma_docgia = te.ma_docgia and ds.isbn = m.isbn and ts.ma_tuasach = ds.ma_tuasach
--				and ds.ma_tuasach = @ma_tuasach
--				group by te.ma_docgia

--			) count2 ON count2.te2 = count1.nl2

--	return
--end
--select * from dbo.f_SL_DauSach_TE__NL_Muon(3)


use QLTV
go
--Câu 9. Vi?t hàm th?c hi?n ch?c n?ng mã hóa ti?ng vi?t.
alter FUNCTION dbo.getHash ( @inputString VARCHAR(20) )
RETURNS VARBINARY(8000)
AS BEGIN
  DECLARE @salt VARCHAR(32)    
 DECLARE @outputHash VARBINARY(8000)
 SET @salt = '9CE08BE9AB824EEF8ABDF4EBCC8ADB19'
 SET @outputHash = HASHBYTES('SHA2_256', (@inputString + @salt))
RETURN @outputHash
END
GO

select dbo.getHash('hi')