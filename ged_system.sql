CREATE DATABASE SiMGeD;
USE SiMGeD;

-- Tabela de usuários
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL, -- Armazenar o hash da senha
    salt VARCHAR(255), -- Salt para senha
    tipo ENUM('cliente', 'auditor', 'admin') NOT NULL, -- Adicionado 'admin' para maior controle
    status ENUM('ativo', 'inativo') DEFAULT 'ativo', -- Adiciona controle de status
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX (email) -- Índice para melhorar a busca por email
);

-- Tabela de departamentos
CREATE TABLE departamentos (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nome_departamento VARCHAR(100) NOT NULL,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo', -- Controle de status para departamentos
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela de colaboradores
CREATE TABLE colaboradores (
    id_colaborador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    foto_3x4 VARCHAR(255), -- Caminho ou URL da foto
    id_departamento INT,
    ativo BOOLEAN DEFAULT TRUE, -- Controle de status ativo/inativo
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento) ON DELETE SET NULL,
    INDEX (id_departamento) -- Índice para melhorar o desempenho de consultas de colaboradores por departamento
);

-- Tabela de documentos
CREATE TABLE documentos (
    id_documento INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    arquivo_pdf VARCHAR(255) NOT NULL, -- Caminho ou URL do arquivo PDF
    id_colaborador INT,
    status ENUM('ativo', 'arquivado', 'excluido') DEFAULT 'ativo', -- Controle de status do documento
    data_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_colaborador) REFERENCES colaboradores(id_colaborador) ON DELETE CASCADE,
    INDEX (status) -- Índice para melhorar o desempenho em consultas filtrando pelo status
);

-- Tabela de logs de auditoria detalhada (auditoria em todas as tabelas)
CREATE TABLE logs_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    tabela_afetada VARCHAR(100) NOT NULL, -- Qual tabela foi afetada
    id_registro INT NOT NULL, -- Qual registro foi afetado
    acao VARCHAR(100) NOT NULL, -- Ação realizada (Insert, Update, Delete)
    detalhes TEXT, -- Detalhes sobre a ação
    motivo TEXT, -- Motivo da alteração (se fornecido)
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX (tabela_afetada), -- Índice para melhorar a consulta por tabela afetada
    INDEX (data_hora) -- Índice para melhorar o desempenho de consultas por data
);

-- Tabela de permissões hierárquicas
CREATE TABLE permissoes (
    id_permissao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_departamento INT, -- Relaciona permissões a departamentos
    entidade VARCHAR(50),
    permissao ENUM('consultar', 'atualizar', 'deletar') NOT NULL,
    nivel_permicao ENUM('baixo', 'medio', 'alto') DEFAULT 'baixo', -- Controle hierárquico de permissões
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento) ON DELETE CASCADE,
    INDEX (id_departamento) -- Índice para melhorar as consultas por departamento
);

-- Tabela de auditoria de documentos (caso haja necessidade de auditoria sobre alterações de documentos)
CREATE TABLE auditoria_documentos (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_documento INT,
    acao VARCHAR(100) NOT NULL, -- Descrição da ação (ex: "Atualização", "Arquivamento")
    dados_anteriores TEXT, -- Dados antes da alteração
    dados_novos TEXT, -- Dados após a alteração
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_documento) REFERENCES documentos(id_documento) ON DELETE CASCADE,
    INDEX (id_documento) -- Índice para melhorar consultas por documento
);

-- Tabela de tipos de documentos (adiciona mais flexibilidade para classificação de documentos)
CREATE TABLE tipos_documentos (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nome_tipo VARCHAR(100) NOT NULL,
    descricao TEXT,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de histórico de documentos (historico completo de alterações em documentos)
CREATE TABLE historico_documentos (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_documento INT,
    id_acao INT,
    id_usuario INT,
    dados_anteriores TEXT, -- Dados antes da alteração
    dados_novos TEXT, -- Dados após a alteração
    motivo TEXT, -- Motivo para a alteração
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_documento) REFERENCES documentos(id_documento) ON DELETE CASCADE,
    FOREIGN KEY (id_acao) REFERENCES tipos_documentos(id_tipo),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

-- Trigger para auditar alterações de documentos
DELIMITER //
CREATE TRIGGER audit_documentos_update
AFTER UPDATE ON documentos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_documentos (id_documento, acao, dados_anteriores, dados_novos)
    VALUES (OLD.id_documento, 'Atualização', CONCAT('Titulo: ', OLD.titulo, ', Descricao: ', OLD.descricao), CONCAT('Titulo: ', NEW.titulo, ', Descricao: ', NEW.descricao));
    INSERT INTO historico_documentos (id_documento, id_acao, id_usuario, dados_anteriores, dados_novos)
    VALUES (NEW.id_documento, 1, OLD.id_colaborador, CONCAT('Titulo: ', OLD.titulo, ', Descricao: ', OLD.descricao), CONCAT('Titulo: ', NEW.titulo, ', Descricao: ', NEW.descricao));
END;
//
DELIMITER ;
