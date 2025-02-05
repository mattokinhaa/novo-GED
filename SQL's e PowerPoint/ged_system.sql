CREATE DATABASE SiMGeD;
USE SiMGeD;

-- Tabela de auditores
CREATE TABLE auditores (
    id_auditor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    senha VARCHAR(255),
    departamento VARCHAR(100),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela de usuários
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    senha VARCHAR(255),
    id_empresa INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empresa) REFERENCES empresas(id_empresa) ON DELETE CASCADE
);

-- Tabela de empresas
CREATE TABLE empresas (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    programa_gerenciamento_risco VARCHAR(255),
    pcmso VARCHAR(255),
    controle_seguranca VARCHAR(255),
    endereco VARCHAR(255),
    email VARCHAR(100),
    telefone VARCHAR(15),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela de funcionários
CREATE TABLE funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    funcao VARCHAR(100),
    aso DATE, 
    contratado BOOLEAN DEFAULT TRUE, -- Indica se o funcionário está ativo
    possui_treinamento BOOLEAN DEFAULT FALSE, -- Treinamento NR ou similar
    possui_documentos BOOLEAN DEFAULT FALSE, -- Documentação em dia
    possui_epi BOOLEAN DEFAULT FALSE, -- EPI em conformidade
    foto VARCHAR(255), -- URL ou caminho da foto
    id_empresa INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empresa) REFERENCES empresas(id_empresa) ON DELETE CASCADE
);

-- Tabela de certificações (NRs e treinamentos)
CREATE TABLE certificacoes (
    id_certificacao INT AUTO_INCREMENT PRIMARY KEY,
    nr_os DATE, 
    nr_06 DATE, 
    nr_10 DATE, 
    nr_11 DATE, 
    nr_12 DATE, 
    nr_13 DATE, 
    nr_17 DATE, 
    nr_18 DATE, 
    nr_20 DATE, 
    nr_33 DATE, 
    id_funcionario INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario) ON DELETE CASCADE
);

-- Índices adicionais para otimização de consultas
CREATE INDEX idx_email_auditor ON auditores(email);
CREATE INDEX idx_email_usuario ON usuarios(email);
CREATE INDEX idx_cnpj_empresa ON empresas(cnpj);
CREATE INDEX idx_cpf_funcionario ON funcionarios(cpf);
CREATE INDEX idx_certificacao_funcionario ON certificacoes(id_funcionario);
