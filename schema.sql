drop database if exists dashboard;
create database dashboard;

use dashboard;

#------------------- REGION ----------------------------

create table if not exists region (
	id   bigint       not null auto_increment,
	name varchar(255) not null unique,

	primary key (id)
);

insert into region (id, name) values
	(1, 'Москва'),
	(2, 'Воронеж'),
	(3, 'Курск'),
	(4, 'Белгород');

#------------------- CUSTOMER ----------------------------

create table if not exists customer (
	id        bigint       not null auto_increment,
	name      varchar(255) not null,
	phone     varchar(100),
	email     varchar(50),
	region_id bigint       not null,

	primary key (id),
	foreign key (region_id) references region (id)
);

insert into customer (id, name, region_id) values
	(1, 'Алексей', 3),
	(2, 'Анна', 2),
	(3, 'Николай', 3),
	(4, 'Даниел', 3),
	(5, 'Константин', 1),
	(6, 'Сергей', 4),
	(7, 'Ульяна', 4);

#------------------- DISTRIBUTOR ----------------------------

create table if not exists distributor (
	id        bigint       not null auto_increment,
	name      varchar(255) not null unique,
	phone     varchar(100),
	email     varchar(50),
	region_id bigint       not null,

	primary key (id),
	foreign key (region_id) references region (id)
);

insert into distributor (id, name, region_id) values
	(1, 'Поставщик 1', 3),
	(2, 'Поставщик 2', 2),
	(3, 'Поставщик 3', 2),
	(4, 'Поставщик 4', 2),
	(5, 'Поставщик 5', 1),
	(6, 'Поставщик 6', 1),
	(7, 'Поставщик 7', 3),
	(8, 'Поставщик 8', 4);

# select r.name, 	d.name from region r join distributor d on r.id = d.region_id;

#------------------- CATEGORY ----------------------------

create table if not exists category (
	id   bigint       not null auto_increment,
	name varchar(255) not null unique,

	primary key (id)
);

insert into category (id, name) values
	(1, 'Одежда'),
	(2, 'Электроника'),
	(3, 'Еда');

#------------------- SUBCATEGORY ----------------------------

create table if not exists sub_category (
	id          bigint       not null auto_increment,
	name        varchar(255) not null unique,
	category_id bigint       not null,

	primary key (id),
	foreign key (category_id) references category (id)
);

insert into sub_category (id, name, category_id) values
	(1, 'Футболки', 1),
	(2, 'Шорты', 1),
	(3, 'Смартфоны', 2),
	(4, 'Ноутбуки', 2),
	(5, 'Фрукты', 3),
	(6, 'Овощи', 3);

# select c.name, sc.name from category c join sub_category sc on c.id = sc.category_id;

#------------------- ITEM ----------------------------

create table if not exists item (
	id              bigint       not null auto_increment,
	name            varchar(255) not null unique,
	sub_category_id bigint       not null,

	primary key (id),
	foreign key (sub_category_id) references sub_category (id)
);

insert into item (id, name, sub_category_id) values
	(1, 'Nike Белая XL', 1),
	(2, 'Demix Красная L', 1),

	(3, 'Addidass Синие L', 2),
	(4, 'Puma Зеленые M', 2),

	(5, 'iPhone 10', 3),
	(6, 'Samsung A9', 3),

	(7, 'MacBook Pro', 4),
	(8, 'Sony Vieo', 4),

	(9, 'Яблоки зеленые', 5),
	(10, 'Клубника', 5),

	(11, 'Картофель', 6),
	(12, 'Томат', 6);

#------------------- CART ----------------------------

create table if not exists cart (
	id          bigint not null auto_increment,
	customer_id bigint not null,
	item_id     bigint not null,
	quantity    double not null,

	primary key (id),
	foreign key (customer_id) references customer (id),
	foreign key (item_id) references item (id)
);

insert into cart (id, customer_id, item_id, quantity) values
	(1, 1, 9, 3.5), # Алексей купил яблоки
	(2, 1, 6, 1), # Алексей купил samsung

	(3, 3, 10, 2.5), # Николай купил клубнику
	(4, 3, 12, 0.5), # Николай купил Томат

	(5, 4, 2, 12), # Даниэль купил Demix Красная L
	(6, 4, 8, 1); # Даниэль купил Sony Vieo

#------------------- ORDER ----------------------------

create table if not exists simple_order (
	id             bigint not null auto_increment,
	distributor_id bigint not null,
	cart_id        bigint not null,
	quantity       double not null,

	primary key (id),
	foreign key (distributor_id) references distributor (id),
	foreign key (cart_id) references cart (id)
);

#------------------- ITEM_N_DIST ----------------------------
create table item_n_dist (
	item_id        bigint not null,
	distributor_id bigint not null,

	foreign key (item_id) references item (id),
	foreign key (distributor_id) references item (id)
);

insert into item_n_dist (item_id, distributor_id) value
	(5, 1),
	(9, 1),
	(2, 1),

	(3, 7),
	(12, 7);
# 	(5, 1), # iphone 10, Поставщик 1
# 	(1, 1), # Nike Белая XL, Поставщик 1
# 	(9, 2), # Яблоки зеленые, Поставщик 2
# 	(12, 3); # Томат, Поставщик 3
#-------------------------------------------------------
# Яблоки попадают +
# Samsung не попадает
# Клубника не попадает
# Томат попадает +
# Demix Красная L попадает +
# Sony Vieo не попадает

select
	r.name,
	d.name,
	c.name,
	i.name,
	crt.quantity
from customer c
	join cart crt on c.id = crt.customer_id
	join item i on crt.item_id = i.id
	join item_n_dist ind on i.id = ind.item_id
	join distributor d on ind.distributor_id = d.id
	join region r on d.region_id = r.id
where c.region_id = 3
order by r.name, d.name, c.name, i.name, crt.quantity
