CREATE DATABASE ex11
GO
USE ex11
GO
CREATE TABLE plano_saude(
codigo INT NOT NULL,
nome VARCHAR(50) NOT NULL,
telefone CHAR(13) NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE paciente (
cpf CHAR(11) NOT NULL,
nome VARCHAR(100) NOT NULL,
rua VARCHAR(50) NOT NULL,
numero INT NOT NULL,
bairro VARCHAR(50) NOT NULL,
telefone CHAR(13) NOT NULL,
plano_saude INT NOT NULL
PRIMARY KEY (cpf)
FOREIGN KEY (plano_saude) REFERENCES plano_saude(codigo)
)
GO
CREATE TABLE medico (
codigo INT IDENTITY(1, 1) NOT NULL,
nome VARCHAR(100) NOT NULL,
especialidade VARCHAR(50) NOT NULL,
plano_saude INT NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (plano_saude) REFERENCES plano_saude(codigo)
)
GO
CREATE TABLE consulta(
codigo_medico INT NOT NULL,
cpf_paciente CHAR(11) NOT NULL,
data_hora DATETIME NOT NULL,
diagnostico VARCHAR(50) NOT NULL
PRIMARY KEY (codigo_medico, cpf_paciente, data_hora)
FOREIGN KEY (codigo_medico) REFERENCES medico(codigo),
FOREIGN KEY (cpf_paciente) REFERENCES paciente(cpf)
)

INSERT INTO plano_saude VALUES
(1234, 'Amil', '41599856'),
(2345, 'Sul América', '45698745'),
(3456, 'Unimed', '48759836'),
(4567, 'Bradesco Saúde', '47265897'),
(5678, 'Intermédica', '41415269')

INSERT INTO paciente VALUES
('85987458920', 'Maria Paula', 'R. Voluntários da Pátria', 589, 'Santana', '98458741', 2345),
('87452136900', 'Ana Julia', 'R. XV de Novembro', 657, 'Centro', '69857412', 5678),
('23659874100', 'João Carlos', 'R. Sete de Setembro', 12, 'República', '74859632', 1234),
('63259874100', 'José Lima', 'R. Anhaia', 768, 'Barra Funda', '96524156', 2345)

INSERT INTO medico VALUES
('Claudio', 'Clínico Geral', 1234),
('Larissa', 'Ortopedista', 2345),
('Juliana', 'Otorrinolaringologista', 4567),
('Sérgio', 'Pediatra', 1234),
('Julio', 'Clínico Geral', 4567),
('Samara', 'Cirurgião', 1234)

INSERT INTO consulta VALUES
(1, '85987458920', '2021-02-10 10:30:00', 'Gripe'),
(2, '23659874100', '2021-02-10 11:00:00', 'Pé Fraturado'),
(4, '85987458920', '2021-02-11 14:00:00', 'Pneumonia'),
(1, '23659874100', '2021-02-11 15:00:00', 'Asma'),
(3, '87452136900', '2021-02-11 16:00:00', 'Sinusite'),
(5, '63259874100', '2021-02-11 17:00:00', 'Rinite'),
(4, '23659874100', '2021-02-11 18:00:00', 'Asma'),
(5, '63259874100', '2021-02-12 10:00:00', 'Rinoplastia')

--Consultar Nome e especialidade dos médicos da Amil
SELECT med.nome, med.especialidade
FROM medico med, plano_saude pla
WHERE med.plano_saude = pla.codigo
	AND pla.nome LIKE 'Amil'

--Consultar Nome, Endereço concatenado, Telefone e Nome do Plano de Saúde de todos os pacientes
SELECT pac.cpf, pac.nome, pac.rua + ' ' + CAST(pac.numero AS VARCHAR) + ' - ' + pac.bairro AS endereco, pac.telefone, pla.nome
FROM paciente pac, plano_saude pla
WHERE pac.plano_saude = pla.codigo

--Consultar Telefone do Plano de  Saúde de Ana Júlia
SELECT pla.telefone
FROM plano_saude pla, paciente pac
WHERE pac.plano_saude = pla.codigo
	AND pac.nome LIKE 'Ana Julia'

--Consultar Plano de Saúde que não tem pacientes cadastrados
SELECT pla.nome
FROM plano_saude pla LEFT OUTER JOIN paciente pac 
ON pla.codigo = pac.plano_saude
WHERE pac.plano_saude IS NULL

--Consultar Planos de Saúde que não tem médicos cadastrados
SELECT pla.nome
FROM plano_saude pla LEFT OUTER JOIN medico med
ON pla.codigo = med.plano_saude
WHERE med.plano_saude IS NULL

--Consultar Data da consulta, Hora da consulta, nome do médico, nome do paciente e diagnóstico de todas as consultas
SELECT CONVERT(VARCHAR(10), con.data_hora, 103) AS data_consulta, CONVERT(VARCHAR(5), con.data_hora, 108) AS hora_consulta,
med.nome, pac.nome, con.diagnostico
FROM consulta con, medico med, paciente pac
WHERE con.codigo_medico = med.codigo
	AND con.cpf_paciente = pac.cpf

--Consultar Nome do médico, data e hora de consulta e diagnóstico de José Lima
SELECT med.nome, CONVERT(VARCHAR(10), con.data_hora, 103) AS data_consulta, CONVERT(VARCHAR(5), con.data_hora, 108) AS hora_consulta
FROM medico med, consulta con, paciente pac
WHERE con.codigo_medico = med.codigo
	AND con.cpf_paciente = pac.cpf
	AND pac.nome LIKE 'José Lima'

--Consultar Diagnóstico e Quantidade de consultas que aquele diagnóstico foi dado (Coluna deve chamar qtd)
SELECT diagnostico, COUNT(diagnostico) AS qtd
FROM consulta
GROUP BY diagnostico

--Consultar Quantos Planos de Saúde que não tem médicos cadastrados
SELECT COUNT(pla.codigo) AS qtd_null
FROM plano_saude pla LEFT OUTER JOIN medico med
ON med.plano_saude = pla.codigo
WHERE med.plano_saude IS NULL

--Alterar o nome de João Carlos para João Carlos da Silva
UPDATE paciente
SET nome = 'João Carlos da Silva'
WHERE nome LIKE 'João Carlos'

--Deletar o plano de Saúde Unimed
DELETE plano_saude
WHERE nome LIKE 'Unimed'

--Renomear a coluna Rua da tabela Paciente para Logradouro
EXEC sp_rename 'paciente.rua', 'logradouro', 'COLUMN'

--Inserir uma coluna, na tabela Paciente, de nome data_nasc e inserir os valores (1990-04-18,1981-03-25,2004-09-04 e 1986-06-18) respectivamente
ALTER TABLE paciente
ADD data_nasc	DATE

UPDATE paciente
SET data_nasc = '1990-04-16'
WHERE cpf = '85987458920'

UPDATE paciente
SET data_nasc = '1981-03-25'
WHERE cpf = '87452136900'

UPDATE paciente
SET data_nasc = '2004-09-04'
WHERE cpf = '23659874100'

UPDATE paciente
SET data_nasc = '1986-06-18'
WHERE cpf = '63259874100'

