CREATE DATABASE SiMGeD;
USE SiMGeD;

-- Tabela de usuários
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL, -- Armazenar o hash da senha
    salt VARCHAR(255), -- Salt para senha
    tipo ENUM('cliente', 'auditor') NOT NULL,
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

-- Tabela de logs de auditoria (geral)
CREATE TABLE logs_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    acao VARCHAR(100) NOT NULL,
    detalhes TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX (id_usuario) -- Índice para melhorar as consultas por usuário
);

-- Tabela de permissões
CREATE TABLE permissoes (
    id_permissao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_departamento INT, -- Relaciona permissões a departamentos
    entidade VARCHAR(50),
    permissao ENUM('consultar', 'atualizar', 'deletar') NOT NULL,
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

-- Tabela de ações (para auditar ações específicas, como criação, atualização ou exclusão)
CREATE TABLE acoes (
    id_acao INT AUTO_INCREMENT PRIMARY KEY,
    nome_acao VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de histórico de documentos (historico completo de alterações em documentos)
CREATE TABLE historico_documentos (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_documento INT,
    id_acao INT,
    id_usuario INT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_documento) REFERENCES documentos(id_documento) ON DELETE CASCADE,
    FOREIGN KEY (id_acao) REFERENCES acoes(id_acao),
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
END;
//
DELIMITER ;
s