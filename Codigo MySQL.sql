-- Criação do banco de dados
CREATE DATABASE Projeto;
USE Projeto;

-- Criação das tabelas

-- Tabela de Usuários
CREATE TABLE USUARIO (
    ID_USUARIO INT(10) UNSIGNED NOT NULL,
    CPF VARCHAR(20) NOT NULL, 
    NOME_USUARIO VARCHAR(30) NOT NULL,
    CARGO_USUARIO VARCHAR(20) NOT NULL,
    TELEFONE INT(15) UNSIGNED NOT NULL, 
    PRIMARY KEY (ID_USUARIO)
);

-- Tabela de Telefones
CREATE TABLE TELEFONE (
    ID_TELEFONE INT(10) UNSIGNED AUTO_INCREMENT NOT NULL,
    TELEFONE VARCHAR(15),
    PRIMARY KEY (ID_TELEFONE)
);

-- Tabela de Fabricantes
CREATE TABLE FABRICANTE (
    CNPJ VARCHAR(20) NOT NULL, 
    NOME_FABR VARCHAR(30) NOT NULL, 
    ID_TELEFONE INT(10) UNSIGNED NOT NULL, 
    EMAIL_FABR VARCHAR(50), 
    ENDERECO_FABR VARCHAR(100) NOT NULL,
    PRIMARY KEY (CNPJ),
    CONSTRAINT FK_ID_TELEFONE FOREIGN KEY (ID_TELEFONE) REFERENCES TELEFONE (ID_TELEFONE)
);

-- Tabela de Cores
CREATE TABLE COR (
    ID_COR INT(11) UNSIGNED NOT NULL, 
    NOME_COR VARCHAR(20) NOT NULL, 
    PRIMARY KEY (ID_COR)
);

-- Tabela de Modelos
CREATE TABLE MODELO (
    ID_MODELO INT(11) UNSIGNED NOT NULL, 
    NOME_MODELO VARCHAR(30) NOT NULL, 
    PRIMARY KEY (ID_MODELO)
);

-- Tabela de Categorias
CREATE TABLE CATEGORIA (
    ID_CATEGORIA INT(11) UNSIGNED NOT NULL,
    TIPO_CATEGORIA VARCHAR(20) NOT NULL, 
    PRIMARY KEY (ID_CATEGORIA)
);

-- Tabela de Produtos
CREATE TABLE PRODUTOS (
    ID_PRODUTO INT(10) AUTO_INCREMENT NOT NULL,
    NOME_PROD VARCHAR(30) NOT NULL, 
    TAMANHO_PROD SMALLINT(3) UNSIGNED NOT NULL, 
    VALOR_PROD DECIMAL(7,2) UNSIGNED NOT NULL, 
    QUANTIDADE_PROD SMALLINT(5) UNSIGNED, 
    DATA_ADICAO_PROD DATE,
    ID_MODELO INT(11) UNSIGNED NOT NULL,
    ID_CATEGORIA INT(11) UNSIGNED NOT NULL,
    ID_COR INT(11) UNSIGNED NOT NULL,
    CNPJ VARCHAR(20) NOT NULL, 
    PRIMARY KEY (ID_PRODUTO),
    CONSTRAINT FK_ID_COR FOREIGN KEY (ID_COR) REFERENCES COR (ID_COR),
    CONSTRAINT FK_CNPJ FOREIGN KEY (CNPJ) REFERENCES FABRICANTE (CNPJ),
    CONSTRAINT FK_ID_MODELO FOREIGN KEY (ID_MODELO) REFERENCES MODELO (ID_MODELO), 
    CONSTRAINT FK_ID_CATEGORIA FOREIGN KEY (ID_CATEGORIA) REFERENCES CATEGORIA (ID_CATEGORIA)
);

-- Tabela de Transações
CREATE TABLE TRANSACAO (
    ID_TRANSACAO INT(10) UNSIGNED AUTO_INCREMENT NOT NULL, 
    DATA_ATUALIZACAO DATE, 
    QUANTIDADE_SAIDA INT(10) UNSIGNED,
    QUANTIDADE_ENTRADA INT(10) UNSIGNED,
    PRIMARY KEY (ID_TRANSACAO)
);

-- Tabela de Relação Usuário-Transação
CREATE TABLE REL_USER_TRANS (
    ID_USUARIO INT(10) UNSIGNED NOT NULL, 
    ID_TRANSACAO INT(10) UNSIGNED NOT NULL, 
    PRIMARY KEY (ID_USUARIO, ID_TRANSACAO),
    CONSTRAINT FK_ID_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO (ID_USUARIO),
    CONSTRAINT FK_ID_TRANSACAO_USUARIO FOREIGN KEY (ID_TRANSACAO) REFERENCES TRANSACAO (ID_TRANSACAO)
);

-- Tabela de Relação Transação-Produto
CREATE TABLE REL_TRANS_PROD (
    ID_TRANSACAO INT(10) UNSIGNED NOT NULL,
    ID_PRODUTO INT(10) NOT NULL,
    CONSTRAINT FK_ID_TRANSACAO_PRODUTO FOREIGN KEY (ID_TRANSACAO) REFERENCES TRANSACAO (ID_TRANSACAO),
    CONSTRAINT FK_ID_PRODUTO FOREIGN KEY (ID_PRODUTO) REFERENCES PRODUTOS (ID_PRODUTO)
);

-- Tabela de Log de Usuários
CREATE TABLE USER_LOG (
    ID_LOG INT AUTO_INCREMENT NOT NULL,
    ID_USUARIO INT(10) UNSIGNED NOT NULL,
    NOME_USUARIO VARCHAR(30) NOT NULL,
    DATA_CRIACAO DATETIME,
    PRIMARY KEY (ID_LOG)
);

-- Tabela de Log de Ações
CREATE TABLE ACTION_LOG (
    ID_ACTION_LOG INT AUTO_INCREMENT NOT NULL,
    ACTION_DESCRIPTION VARCHAR(255),
    ACTION_DATE DATETIME,
    PRIMARY KEY (ID_ACTION_LOG)
);

-- Stored Procedures

-- Stored Procedure para adicionar um novo produto ao banco de dados.
DELIMITER //
CREATE PROCEDURE AddProduct(
    IN p_NOME_PROD VARCHAR(30),
    IN p_TAMANHO_PROD SMALLINT,
    IN p_VALOR_PROD DECIMAL(7,2),
    IN p_QUANTIDADE_PROD SMALLINT,
    IN p_DATA_ADICAO_PROD DATE,
    IN p_ID_MODELO INT,
    IN p_ID_CATEGORIA INT,
    IN p_ID_COR INT,
    IN p_CNPJ VARCHAR(20)
)
BEGIN
    -- Declara uma variável local para armazenar informações de log.
    DECLARE textoLog VARCHAR(255);
    
    -- Insere os dados do produto na tabela PRODUTOS.
    INSERT INTO PRODUTOS 
        (NOME_PROD, TAMANHO_PROD, VALOR_PROD, QUANTIDADE_PROD, DATA_ADICAO_PROD, ID_MODELO, ID_CATEGORIA, ID_COR, CNPJ)
    VALUES 
        (p_NOME_PROD, p_TAMANHO_PROD, p_VALOR_PROD, p_QUANTIDADE_PROD, p_DATA_ADICAO_PROD, p_ID_MODELO, p_ID_CATEGORIA, p_ID_COR, p_CNPJ);
    
    -- Cria uma mensagem de log para o produto adicionado.
    SET textoLog = CONCAT('PRODUTO ADICIONADO [', p_NOME_PROD, '] ID [', LAST_INSERT_ID(), ']');
    
    -- Chama a stored procedure para inserir a ação no log.
    CALL insertActionLog(textoLog);
END //
DELIMITER ;

-- Stored Procedure para atualizar a quantidade em estoque de um produto.
DELIMITER //
CREATE PROCEDURE UpdateProductStock(
    IN p_ID_PRODUTO INT,
    IN p_QUANTIDADE_PROD INT
)
BEGIN
    -- Declara uma variável local para armazenar informações de log.
    DECLARE textoLog VARCHAR(255);
    
    -- Atualiza a quantidade em estoque do produto na tabela PRODUTOS.
    UPDATE PRODUTOS
    SET QUANTIDADE_PROD = p_QUANTIDADE_PROD
    WHERE ID_PRODUTO = p_ID_PRODUTO;
    
    -- Cria uma mensagem de log para a atualização do estoque do produto.
    SET textoLog = CONCAT('PRODUTO EM ESTOQUE ALTERADO [ID:', p_ID_PRODUTO, '] QUANTIDADE: ', p_QUANTIDADE_PROD);
    
    -- Chama a stored procedure para inserir a ação no log.
    CALL insertActionLog(textoLog);
END //
DELIMITER;

-- Stored Procedure para obter os detalhes de um produto pelo seu ID.
DELIMITER //
CREATE PROCEDURE GetProductDetails(
    IN p_ID_PRODUTO INT
)
BEGIN
    -- Retorna os detalhes do produto da tabela PRODUTOS.
    SELECT * FROM PRODUTOS
    WHERE ID_PRODUTO = p_ID_PRODUTO;
END //
DELIMITER;

-- Stored Procedure para adicionar uma nova transação ao banco de dados.
DELIMITER //
CREATE PROCEDURE AddTransaction(
    IN p_QUANTIDADE_SAIDA INT,
    IN p_QUANTIDADE_ENTRADA INT
)
BEGIN
    -- Declara uma variável local para armazenar informações de log.
    DECLARE textoLog VARCHAR(255);
    
    -- Insere os dados da transação na tabela TRANSACAO.
    INSERT INTO TRANSACAO (DATA_ATUALIZACAO, QUANTIDADE_SAIDA, QUANTIDADE_ENTRADA)
    VALUES (CURDATE(), p_QUANTIDADE_SAIDA, p_QUANTIDADE_ENTRADA);
    
    -- Cria uma mensagem de log para a transação incluída.
    SET textoLog = CONCAT('TRANSAÇÃO INCLUÍDA. QUANTIDADE ENTRADA: ', p_QUANTIDADE_ENTRADA, ', QUANTIDADE SAÍDA: ', p_QUANTIDADE_SAIDA);
END //
DELIMITER;

-- Stored Procedure para obter as transações de um usuário pelo seu ID.
DELIMITER //
CREATE PROCEDURE GetTransactionsByUser(
    IN p_ID_USUARIO INT
)
BEGIN
    -- Retorna as transações do usuário da tabela TRANSACAO, baseado na tabela REL_USER_TRANS.
    SELECT t.* FROM TRANSACAO t
    JOIN REL_USER_TRANS rut ON t.ID_TRANSACAO = rut.ID_TRANSACAO
    WHERE rut.ID_USUARIO = p_ID_USUARIO;
END //
DELIMITER ;

-- Stored Procedure para inserir uma ação no log de ações.
DELIMITER //
CREATE PROCEDURE insertActionLog(
    IN p_ACTION_DESCRIPTION VARCHAR(255)
)
BEGIN 
    -- Insere a descrição da ação e a data atual na tabela ACTION_LOG.
    INSERT INTO ACTION_LOG 
    (
        ACTION_DESCRIPTION,
        ACTION_DATE
    )
    VALUES 
    (
        p_ACTION_DESCRIPTION, 
        NOW()
    );
END//
DELIMITER;

-- Cursores

-- Cursor para buscar todos os usuários com seus números de telefone
DELIMITER //

CREATE PROCEDURE FetchUsersWithPhones()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE user_id INT;
    DECLARE user_name VARCHAR(30);
    DECLARE telephone_number VARCHAR(15);
    
    DECLARE cursor_users CURSOR FOR
        SELECT u.ID_USUARIO, u.NOME_USUARIO, t.TELEFONE
        FROM USUARIO u
        JOIN TELEFONE t ON u.TELEFONE = t.ID_TELEFONE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_users;

    fetch_loop: LOOP
        FETCH cursor_users INTO user_id, user_name, telephone_number;
        IF done THEN
            LEAVE fetch_loop;
        END IF;
        
        -- Processar dados do usuário
        SELECT user_id, user_name, telephone_number;
    END LOOP;

    CLOSE cursor_users;
END //

DELIMITER ;

-- Cursor para calcular o valor total dos produtos em estoque
DELIMITER //

CREATE PROCEDURE CalculateTotalStockValue()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE total_value DECIMAL(10,2) DEFAULT 0;
    DECLARE product_id INT;
    DECLARE product_value DECIMAL(10,2);
    DECLARE product_quantity INT;

    DECLARE cursor_products CURSOR FOR
        SELECT ID_PRODUTO, VALOR_PROD, QUANTIDADE_PROD
        FROM PRODUTOS;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_products;

    fetch_loop: LOOP
        FETCH cursor_products INTO product_id, product_value, product_quantity;
        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- Calcular valor total para cada produto
        SET total_value = total_value + (product_value * product_quantity);
    END LOOP;

    CLOSE cursor_products;

    -- Exibir valor total de todos os produtos
    SELECT total_value AS total_value_of_stock;
END //

DELIMITER ;

-- Cursor para encontrar produtos de uma categoria específica e atualizar seu preço
DELIMITER //

DELIMITER //

CREATE PROCEDURE UpdateProductPricesByCategory(
    IN p_ID_CATEGORIA INT, 
    IN p_VALOR_PRODUTO DECIMAL(10,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE product_id INT;
    DECLARE product_value DECIMAL(10,2);
    DECLARE textLog VARCHAR(255);
    
    DECLARE cursor_products_to_update CURSOR FOR
        SELECT ID_PRODUTO, VALOR_PROD
        FROM PRODUTOS
        WHERE ID_CATEGORIA = p_ID_CATEGORIA;  -- Atualizar produtos na categoria inserida
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_products_to_update;

    fetch_loop: LOOP
        FETCH cursor_products_to_update INTO product_id, product_value;
        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- Atualizar o preço de cada produto na categoria
        UPDATE PRODUTOS
        SET VALOR_PROD = product_value + p_VALOR_PRODUTO
        WHERE ID_PRODUTO = product_id;
        
        SET textLog = CONCAT('PRODUTO ID', '[', product_id, '] ADICIONADO VALOR DE R$ ', p_VALOR_PRODUTO);
        
        CALL insertActionLog(textLog);
    END LOOP;

    CLOSE cursor_products_to_update;
END //

DELIMITER ;

-- Cursor para gerar um relatório de transações com detalhes do produto
DELIMITER //

CREATE PROCEDURE GenerateTransactionReport()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE transaction_id INT;
    DECLARE transaction_date DATE;
    DECLARE product_name VARCHAR(30);
    DECLARE product_value DECIMAL(7,2);
    DECLARE product_quantity SMALLINT;
    
    DECLARE cursor_transactions CURSOR FOR
        SELECT t.ID_TRANSACAO, t.DATA_ATUALIZACAO, p.NOME_PROD, p.VALOR_PROD, p.QUANTIDADE_PROD
        FROM TRANSACAO t
        JOIN REL_TRANS_PROD rtp ON t.ID_TRANSACAO = rtp.ID_TRANSACAO
        JOIN PRODUTOS p ON rtp.ID_PRODUTO = p.ID_PRODUTO;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_transactions;

    fetch_loop: LOOP
        FETCH cursor_transactions INTO transaction_id, transaction_date, product_name, product_value, product_quantity;
        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- Processar dados da transação e produto para o relatório
        SELECT transaction_id, transaction_date, product_name, product_value, product_quantity;
    END LOOP;

    CLOSE cursor_transactions;
END //

DELIMITER ;

-- Cursor para identificar usuários inativos
DELIMITER //

CREATE PROCEDURE IdentifyInactiveUsers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE user_id INT;
    DECLARE user_name VARCHAR(30);
    DECLARE last_transaction_date DATE;
    
    DECLARE cursor_inactive_users CURSOR FOR
        SELECT u.ID_USUARIO, u.NOME_USUARIO, t.DATA_ATUALIZACAO
        FROM USUARIO u
        INNER JOIN rel_user_trans ut ON u.ID_USUARIO = ut.ID_USUARIO
        INNER JOIN TRANSACAO t ON ut.ID_TRANSACAO = t.ID_TRANSACAO
        WHERE t.ID_TRANSACAO IS NULL OR t.DATA_ATUALIZACAO < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_inactive_users;

    fetch_loop: LOOP
        FETCH cursor_inactive_users INTO user_id, user_name, last_transaction_date;
        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- Processar dados de usuário inativo
        SELECT user_id, user_name, last_transaction_date;
    END LOOP;

    CLOSE cursor_inactive_users;
END //

DELIMITER ;

-- Triggers

-- Gatilho para validar CPF na inserção ou atualização na tabela USUARIO

DELIMITER //

CREATE TRIGGER validate_cpf_before_insert 
BEFORE INSERT ON USUARIO
FOR EACH ROW
BEGIN
  -- Remover pontos e traços do CPF
  SET @cpf_valido = REPLACE(REPLACE(NEW.CPF, '.', ''), '-', '');

  -- Verificar se o CPF tem 11 dígitos e se é composto apenas por números
  IF CHAR_LENGTH(@cpf_valido) <> 11 OR @cpf_valido REGEXP '[^0-9]' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CPF inválido!';
  END IF;
END //

DELIMITER ;

-- Gatilho para registrar a criação de usuário em uma tabela separada
DELIMITER //

CREATE TRIGGER log_user_creation 
AFTER INSERT ON USUARIO
FOR EACH ROW
BEGIN
  INSERT INTO USER_LOG (ID_USUARIO, NOME_USUARIO, DATA_CRIACAO)
  VALUES (NEW.ID_USUARIO, NEW.NOME_USUARIO, NOW());
END //

DELIMITER ;

-- Gatilho para atualizar a quantidade de produtos na tabela PRODUTOS
DELIMITER //

CREATE TRIGGER update_product_quantity  
AFTER INSERT ON TRANSACAO 
FOR EACH ROW 
BEGIN
  DECLARE quantidade_total INT;
  DECLARE v_id_produto INT;

  -- Selecionar ID_PRODUTO e QUANTIDADE_PROD para a transação inserida
  SELECT tp.ID_PRODUTO, p.QUANTIDADE_PROD INTO v_id_produto, quantidade_total
  FROM rel_trans_prod tp
  INNER JOIN PRODUTOS p ON tp.ID_PRODUTO = p.ID_PRODUTO
  WHERE tp.ID_TRANSACAO = NEW.ID_TRANSACAO;

  -- Calcular a nova quantidade total
  SET quantidade_total = quantidade_total + NEW.QUANTIDADE_ENTRADA;

  -- Atualizar a quantidade total do produto na tabela PRODUTOS
  UPDATE PRODUTOS
  SET QUANTIDADE_PROD = quantidade_total
  WHERE ID_PRODUTO = v_id_produto;
END//

DELIMITER ;

-- Gatilho para validar o estoque do produto antes de inserir ou atualizar na tabela TRANSACAO
DELIMITER //

CREATE TRIGGER validate_stock 
BEFORE UPDATE ON TRANSACAO
FOR EACH ROW
BEGIN
  DECLARE quantidade_em_estoque INT;

  SELECT p.QUANTIDADE_PROD INTO quantidade_em_estoque 
  FROM rel_trans_prod tp
  INNER JOIN PRODUTOS p ON tp.ID_PRODUTO = p.ID_PRODUTO
  WHERE tp.ID_TRANSACAO = NEW.ID_TRANSACAO;

  IF NEW.QUANTIDADE_SAIDA > quantidade_em_estoque THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente!';
  END IF;
END //

DELIMITER ;

-- Gatilho para atualizar a categoria do produto quando o modelo for alterado na tabela PRODUTOS
DELIMITER //

CREATE TRIGGER update_category_on_model_change 
AFTER UPDATE ON PRODUTOS
FOR EACH ROW
BEGIN
  IF NEW.ID_MODELO <> OLD.ID_MODELO THEN
    UPDATE PRODUTOS
    SET ID_CATEGORIA = (SELECT ID_CATEGORIA FROM MODELO WHERE ID_MODELO = NEW.ID_MODELO)
    WHERE ID_PRODUTO = NEW.ID_PRODUTO;
  END IF;
END //

DELIMITER ;


-- Inserções

-- Inserindo Usuários
INSERT INTO USUARIO (ID_USUARIO, CPF, NOME_USUARIO, CARGO_USUARIO, TELEFONE)
VALUES (1, '12345678900', 'João da Silva', 'Gerente', 1);

INSERT INTO USUARIO (ID_USUARIO, CPF, NOME_USUARIO, CARGO_USUARIO, TELEFONE)
VALUES (2, '98765432100', 'Maria de Souza', 'Vendedor', 2);

INSERT INTO USUARIO (ID_USUARIO, CPF, NOME_USUARIO, CARGO_USUARIO, TELEFONE)
VALUES (4, '34567532198', 'Luiz Alberto', 'Analista', 3);

-- Inserindo Telefones
INSERT INTO TELEFONE (TELEFONE)
VALUES ('11999999999');

INSERT INTO TELEFONE (TELEFONE)
VALUES ('11888888888');

INSERT INTO TELEFONE (TELEFONE)
VALUES ('1140028922');

-- Inserindo Fabricantes
INSERT INTO FABRICANTE (CNPJ, NOME_FABR, ID_TELEFONE, EMAIL_FABR, ENDERECO_FABR)
VALUES ('1234567890000', 'Empresa A', 1, 'empresaa@email.com', 'Rua A, 100, São Paulo - SP');

INSERT INTO FABRICANTE (CNPJ, NOME_FABR, ID_TELEFONE, EMAIL_FABR, ENDERECO_FABR)
VALUES ('9876543210000', 'Empresa B', 2, 'empresab@email.com', 'Rua B, 200, São Paulo - SP');

-- Inserindo Cores
INSERT INTO COR (ID_COR, NOME_COR)
VALUES (1, 'Vermelho');

INSERT INTO COR (ID_COR, NOME_COR)
VALUES (2, 'Azul');

INSERT INTO COR (ID_COR, NOME_COR)
VALUES (3, 'Preto');

-- Inserindo Modelos
INSERT INTO MODELO (ID_MODELO, NOME_MODELO)
VALUES (1, 'Samsung');

INSERT INTO MODELO (ID_MODELO, NOME_MODELO)
VALUES (2, 'Apple');

INSERT INTO MODELO (ID_MODELO, NOME_MODELO)
VALUES (3, 'Chevrolet');

-- Inserindo Categorias
INSERT INTO CATEGORIA (ID_CATEGORIA, TIPO_CATEGORIA)
VALUES (1, 'Eletrônicos');

INSERT INTO CATEGORIA (ID_CATEGORIA, TIPO_CATEGORIA)
VALUES (2, 'Automóveis');

-- Inserindo Produtos
INSERT INTO PRODUTOS (NOME_PROD, TAMANHO_PROD, VALOR_PROD, QUANTIDADE_PROD, DATA_ADICAO_PROD, ID_MODELO, ID_CATEGORIA, ID_COR, CNPJ)
VALUES ('TV 50"', 50, 2500.00, 100, '2023-07-20', 1, 1, 1, '1234567890000');

INSERT INTO PRODUTOS (NOME_PROD, TAMANHO_PROD, VALOR_PROD, QUANTIDADE_PROD, DATA_ADICAO_PROD, ID_MODELO, ID_CATEGORIA, ID_COR, CNPJ)
VALUES ('Celular iPhone 14', 6.1, 7500.00, 200, '2023-07-20', 2, 1, 2, '1234567890000');

INSERT INTO PRODUTOS (NOME_PROD, TAMANHO_PROD, VALOR_PROD, QUANTIDADE_PROD, DATA_ADICAO_PROD, ID_MODELO, ID_CATEGORIA, ID_COR, CNPJ)
VALUES ('Celular iPhone 15', 6.1, 15000.00, 200, '2023-07-20', 2, 1, 2, '1234567890000');

-- Inserindo Transações
INSERT INTO TRANSACAO (DATA_ATUALIZACAO, QUANTIDADE_SAIDA, QUANTIDADE_ENTRADA)
VALUES ('2023-07-25', 5, 0); -- ID_TRANSACAO será 1

INSERT INTO TRANSACAO (DATA_ATUALIZACAO, QUANTIDADE_SAIDA, QUANTIDADE_ENTRADA)
VALUES ('2023-07-26', 0, 10); -- ID_TRANSACAO será 2

-- Inserindo Relação Usuário-Transação
INSERT INTO REL_USER_TRANS (ID_USUARIO, ID_TRANSACAO)
VALUES (1, 1);

INSERT INTO REL_USER_TRANS (ID_USUARIO, ID_TRANSACAO)
VALUES (2, 2);

-- Inserindo Relação Transação-Produto
INSERT INTO REL_TRANS_PROD (ID_TRANSACAO, ID_PRODUTO)
VALUES (1, 1); -- Transação 1 relacionada ao Produto 1

INSERT INTO REL_TRANS_PROD (ID_TRANSACAO, ID_PRODUTO)
VALUES (2, 2); -- Transação 2 relacionada ao Produto 2`

-- Transações

-- Transação 1: Adicionar produto e registrar ação
START TRANSACTION;

CALL AddProduct('Produto X', 10, 100.00, 50, CURDATE(), 1, 1, 1, '1234567890000');

COMMIT;

-- Transação 2: Atualizar estoque e registrar ação
START TRANSACTION;

CALL UpdateProductStock(1, 75);

COMMIT;

-- Transação 3: Adicionar transação e registrar ação
START TRANSACTION;

CALL AddTransaction(10, 0);

COMMIT;

-- Transação 4: Adicionar usuário e registrar ação
START TRANSACTION;

INSERT INTO USUARIO (ID_USUARIO, CPF, NOME_USUARIO, CARGO_USUARIO, TELEFONE) VALUES (3, '11223344556', 'Carlos Pereira', 'Analista', 1177777777);
INSERT INTO ACTION_LOG (ACTION_DESCRIPTION, ACTION_DATE) VALUES ('Usuário Carlos Pereira adicionado', NOW());

COMMIT;

-- Transação 5: Atualizar preço de produto e registrar ação
START TRANSACTION;

UPDATE PRODUTOS SET VALOR_PROD = VALOR_PROD + 50 WHERE ID_PRODUTO = 2;
INSERT INTO ACTION_LOG (ACTION_DESCRIPTION, ACTION_DATE) VALUES ('Preço do Produto ID 2 atualizado', NOW());

COMMIT;

-- Procedures utilizadas para teste
START TRANSACTION;

CALL AddProduct('Produto Exemplo', 10, 99.99, 50, '2024-05-29', 1, 1, 1, '1234567890000');
CALL UpdateProductStock(6, 500);
CALL UpdateProductPricesByCategory(1, 400);

COMMIT;