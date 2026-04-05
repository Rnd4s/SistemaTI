-- ====================================================================================
-- PROJETO FINAL - N1
-- NOME: RHANDAL REIS MOURA
-- CURSO: ENGENHARIA DE COMPUTAÇÃO
-- ====================================================================================

EXEC sp_MSforeachtable 'Select * from ?'; -- COMANDO PARA VER TODAS AS TABELAS

-- ------------------------------------------------------------------------------------
-- 1. Deve possuir no mínimo sete tabelas (CREATE TABLE);
-- 7. Deve possuir pelo menos uma restrição exclusiva com CONSTRAINT UNIQUE;
-- 8. Deve possuir cláusula DEFAULT;
-- ------------------------------------------------------------------------------------

CREATE TABLE Departamentos (
    id_departamento INT PRIMARY KEY,
    nome_departamento VARCHAR(50) NOT NULL
);

CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) CONSTRAINT uq_email UNIQUE,
    id_departamento INT FOREIGN KEY REFERENCES Departamentos(id_departamento)
);

CREATE TABLE Tecnicos (
    id_tecnico INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(50)
);

CREATE TABLE Categorias (
    id_categoria INT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE Equipamentos (
    id_equipamento INT PRIMARY KEY,
    patrimonio VARCHAR(20) CONSTRAINT uq_patrimonio UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    id_usuario INT FOREIGN KEY REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Chamados (
    id_chamado INT PRIMARY KEY,
    id_usuario INT NOT NULL FOREIGN KEY REFERENCES Usuarios(id_usuario),
    id_tecnico INT FOREIGN KEY REFERENCES Tecnicos(id_tecnico),
    id_equipamento INT FOREIGN KEY REFERENCES Equipamentos(id_equipamento),
    id_categoria INT FOREIGN KEY REFERENCES Categorias(id_categoria),
    descricao_problema VARCHAR(100) NOT NULL,
    status_chamado VARCHAR(20) DEFAULT 'Aberto', -- Status 'Aberto' automático
    data_abertura DATETIME DEFAULT GETDATE()     -- Data/hora exata do computador
);

CREATE TABLE Acompanhamentos (
    id_acompanhamento INT PRIMARY KEY,
    id_chamado INT NOT NULL FOREIGN KEY REFERENCES Chamados(id_chamado),
    descricao_andamento VARCHAR(50) NOT NULL,
    data_registro DATETIME DEFAULT GETDATE()
);
GO 

-- 6. Criação de Trigger 

CREATE TRIGGER TGR_STATUS
ON Acompanhamentos
AFTER INSERT 
AS
BEGIN
    UPDATE Chamados SET status_chamado = 'Em Andamento'
    WHERE id_chamado IN (SELECT id_chamado FROM inserted); 
END;
GO

-- 7. CRIAÇÃO DE FUNÇÃO

CREATE FUNCTION dbo.fn_DiasEmAberto (@DataAbertura datetime)
RETURNS INT
AS
BEGIN
    DECLARE @Dias INT
    SET @Dias = DATEDIFF(DAY, @DataAbertura, GETDATE())
    RETURN @Dias
END;
GO

-- ------------------------------------------------------------------------------------
-- INSERT DE DADOS 
-- ------------------------------------------------------------------------------------

INSERT INTO Departamentos (id_departamento, nome_departamento) VALUES (1, 'Recursos Humanos'), (2, 'Financeiro'), (3, 'Diretoria');

INSERT INTO Usuarios (id_usuario, nome, email, id_departamento) VALUES (1, 'Ana Silva', 'ana@teste.com', 1), (2, 'Carlos Souza', 'carlos@teste.com', 2); 

INSERT INTO Tecnicos (id_tecnico, nome, especialidade) VALUES (1, 'Marcos TI', 'Redes'), (2, 'Julia Suporte', 'Hardware');

INSERT INTO Categorias (id_categoria, nome_categoria) VALUES (1, 'Problema de Hardware'), (2, 'Sem Internet');

INSERT INTO Equipamentos (id_equipamento, patrimonio, modelo, id_usuario) VALUES (1, 'PTR-001', 'Notebook Dell', 1), (2, 'SBC-001', 'Single-Board Computer', 2), (3, 'CAM-001', 'Camera de Visao', 1);

INSERT INTO Chamados (id_chamado, id_usuario, id_tecnico, id_equipamento, id_categoria, descricao_problema) VALUES (1, 1, 1, 1, 2, 'Meu notebook não conecta no Wi-Fi'), (2, 2, 2, 2, 1, 'Falha na integração de Hardware');

INSERT INTO Acompanhamentos (id_acompanhamento, id_chamado, descricao_andamento) VALUES (1, 1, 'Reiniciei o roteador e a internet voltou.');
GO

-- ------------------------------------------------------------------------------------
-- CONDIÇÃO IIF
-- ------------------------------------------------------------------------------------

SELECT id_categoria, id_chamado, descricao_problema,
        IIF(id_categoria = 1, 'Urgente', 'Normal') AS Prioridade_Atendimento
        FROM Chamados; 

-- ------------------------------------------------------------------------------------
-- CONDIÇÃO IF
-- ------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM Equipamentos WHERE modelo = 'Camera de Visao')
BEGIN
    PRINT 'Camera registrada e pronta para uso!'
    END
    ELSE BEGIN
    PRINT 'Camera ainda não foi registrada. Verifique novamente'
END

-- ------------------------------------------------------------------------------------
-- CASE WHEN
-- ------------------------------------------------------------------------------------

SELECT id_equipamento, modelo,
    CASE
        WHEN modelo = 'Notebook Dell' THEN 'Equipamento de Usuário'
        WHEN modelo = 'Single-Board Computer' THEN 'Placa de Processamento'
        ELSE 'Periférico de Visão'
    END AS 'Categoria_Hardware'
FROM Equipamentos;

-- ------------------------------------------------------------------------------------
-- WHILE (Utilizando CONTINUE e BREAK)
-- ------------------------------------------------------------------------------------

DECLARE @CameraID int = 1;

    WHILE @CameraID <= 10
BEGIN
        IF @CameraID = 4
        BEGIN
            PRINT 'Camera em manutenção'
            SET @CameraID = @CameraID + 1;
            CONTINUE; 
        END

        IF @CameraID = 8
        BEGIN
            PRINT 'FALHA CRÍTICA'
            SET @CameraID = @CameraID + 1;
            BREAK; 
        END

        PRINT 'TESTE DE CAMERA ' + CAST(@CameraID as VARCHAR) + '... OK'
        SET @CameraID = @CameraID + 1; 
END

-- ------------------------------------------------------------------------------------
-- USO DA FUNÇÃO 
-- ------------------------------------------------------------------------------------

SELECT 
    id_chamado, 
    descricao_problema, 
    data_abertura,
    dbo.fn_DiasEmAberto(data_abertura) AS dias_pendentes
FROM Chamados;