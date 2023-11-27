CREATE DATABASE ex07
GO
USE ex07
GO
CREATE TABLE cliente(
rg			CHAR(9) 		NOT NULL,
cpf			VARCHAR(13)		NOT NULL,
nome		VARCHAR(70) 	NOT NULL,
logradouro	VARCHAR(100)	NOT NULL,
numero		INT				NOT NULL
PRIMARY KEY(rg)
)
GO
CREATE TABLE pedido(
nota_fiscal		INT			NOT NULL	IDENTITY(1001, 1),
valor			INT			NOT NULL,
data_pedido		DATE		NOT NULL,
rg_cliente		CHAR(9) 	NOT NULL
PRIMARY KEY(nota_fiscal)
FOREIGN KEY(rg_cliente) REFERENCES cliente(rg)
)
GO
CREATE TABLE fornecedor(
codigo 			INT 			NOT NULL	IDENTITY,
nome			VARCHAR(50)		NOT NULL,
logradouro		VARCHAR(100)	NOT NULL,
numero			INT				NULL,
pais			CHAR(3)			NOT NULL,
area 			INT				NOT NULL,
telefone		CHAR(11)		NULL,
cnpj			CHAR(14)		NULL,
cidade			VARCHAR(30)		NULL,
transporte		VARCHAR(30)		NULL,
moeda			CHAR(5)			NOT NULL
PRIMARY KEY(codigo)
)
GO
CREATE TABLE mercadoria(
codigo			INT 			NOT NULL	IDENTITY(10, 1),
descricao		VARCHAR(100)	NOT NULL,
preco			INT				NOT NULL,
quantidade		INT				NOT NULL,
cod_fornecedor	INT				NOT NULL
PRIMARY KEY(codigo)
FOREIGN KEY(cod_fornecedor) REFERENCES fornecedor(codigo)
)
GO
INSERT INTO cliente VALUES
('29531844', '34519878040', 'Luiz André', 'R. Astorga', 500),
('13514996x', '84984285630', 'Maria Luiza', 'R. Piauí', 174),
('121985541', '23354997310', 'Ana Barbara', 'Av. Jaceguai', 1141),
('23987746x', '43587669920', 'Marcos Alberto', 'R. Quinze', 22)
GO
INSERT INTO pedido VALUES
(754, '2018-04-01', '121985541'),
(350, '2018-04-02', '121985541'),
(30, '2018-04-02', '29531844'),
(1500, '2018-04-03', '13514996x')
GO
INSERT INTO fornecedor VALUES
('Clone', 'Av. Nações Unidas', 12000, 'BR', 55, '1141487000', NULL, 'São Paulo', NULL, 'R$'),
('Logitech', '28th Street', 100, 'USA', 1, '2127695100', NULL, NULL, 'Avião', 'US$'),
('LG', 'Rod. Castello Branco', NULL, 'BR', 55, '800664400', '4159978100001', 'Sorocaba', NULL, 'R$'),
('PcChips', 'Ponte da Amizade', NULL, 'PY', 595, NULL, NULL, NULL, 'Navio', 'US$')
GO
INSERT INTO mercadoria VALUES
('Mouse', 24, 30, 1),
('Teclado', 50, 20, 1),
('Cx. De Som', 30, 8, 2),
('Monitor 17', 350, 4, 3),
('Notebook', 1500, 7, 4)

--Consultar 10% de desconto no pedido 1003
SELECT (valor * 0.90) AS desconto
FROM pedido
WHERE nota_fiscal = 1003

--Consultar 5% de desconto em pedidos com valor maior de R$700,00
SELECT (valor * 0.95) AS desconto
FROM pedido
WHERE valor > 700

--Consultar e atualizar aumento de 20% no valor de marcadorias com estoque menor de 10
SELECT (preco * 1.20) AS aumento
FROM mercadoria
WHERE quantidade < 10

UPDATE mercadoria
SET preco = preco * 1.20
WHERE quantidade < 10

--Data e valor dos pedidos do Luiz
SELECT ped.data_pedido, ped.valor
FROM pedido ped, cliente cli
WHERE ped.rg_cliente = cli.rg
	AND cli.nome LIKE 'Luiz%'

--CPF, Nome e endereço concatenado do cliente de nota 1004
SELECT SUBSTRING(cli.cpf, 1, 3)+'.'+SUBSTRING(cli.cpf, 4, 3)+'.'+SUBSTRING(cli.cpf, 7, 3)+'-'+SUBSTRING(cli.cpf, 10, 2) AS cpf, cli.nome, (cli.logradouro + ' ' + CAST(cli.numero AS VARCHAR)) AS endereco
FROM pedido ped, cliente cli
WHERE ped.rg_cliente = cli.rg
	AND ped.nota_fiscal = 1004

--País e meio de transporte da Cx. De som
SELECT forn.pais, forn.transporte
FROM fornecedor forn, mercadoria pro
WHERE pro.cod_fornecedor = forn.codigo
	AND pro.descricao LIKE 'Cx. De Som'

--Nome e Quantidade em estoque dos produtos fornecidos pela Clone
SELECT pro.descricao, pro.quantidade
FROM fornecedor forn, mercadoria pro
WHERE pro.cod_fornecedor = forn.codigo
	AND forn.nome LIKE 'Clone'

--Endereço concatenado e telefone dos fornecedores do monitor. (Telefone brasileiro (XX)XXXX-XXXX ou XXXX-XXXXXX (Se for 0800), Telefone Americano (XXX)XXX-XXXX)
SELECT (forn.logradouro + ' ' + CAST(forn.numero AS VARCHAR) AS endereco, 
	CASE WHEN(forn.pais = 'BR') THEN
	'(' + SUBSTRING() + ') ' + 

--Tipo de moeda que se compra o notebook
SELECT forn.moeda
FROM fornecedor forn, mercadoria pro
WHERE pro.cod_fornecedor = forn.codigo
	AND pro.descricao LIKE 'Notebook'

--Considerando que hoje é 03/02/2019, há quantos dias foram feitos os pedidos e, criar uma coluna que escreva Pedido antigo para
--pedidos feitos há mais de 6 meses e pedido recente para os outros
SELECT DATEDIFF(DAY, data_pedido, GETDATE()) AS quantos_dias, 
	CASE WHEN(DATEDIFF(MONTH, data_pedido, GETDATE()) > 6) THEN
	'Pedido Antigo' ELSE 'Pedido Recente' END AS estado_pedido
FROM pedido

--Nome e Quantos pedidos foram feitos por cada cliente
SELECT cli.nome, COUNT(ped.rg_cliente) AS quantidade_pedidos
FROM cliente cli, pedido ped
WHERE ped.rg_cliente = cli.rg
GROUP BY cli.nome

--RG,CPF,Nome e Endereço dos cliente cadastrados que Não Fizeram pedidos
SELECT CASE WHEN(cli.rg LIKE '%x') THEN
	SUBSTRING(cli.rg, 1, 8) + '-' + SUBSTRING(cli.rg, 9, 1) END AS rg,
	SUBSTRING(cli.cpf, 1, 3)+'.'+SUBSTRING(cli.cpf, 4, 3)+'.'+SUBSTRING(cli.cpf, 7, 3)+'-'+SUBSTRING(cli.cpf, 10, 2) AS cpf,
	cli.nome, (cli.logradouro + ' ' + CAST(cli.numero AS VARCHAR)) AS endereco
FROM cliente cli LEFT OUTER JOIN pedido ped
ON ped.rg_cliente = cli.rg
WHERE ped.rg_cliente IS NULL
