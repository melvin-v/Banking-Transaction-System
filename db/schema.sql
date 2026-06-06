CREATE TABLE Cliente (
 ClienteId INT IDENTITY PRIMARY KEY,
 Nombre NVARCHAR(160) NOT NULL,
 TipoDocumento CHAR(3) NOT NULL, -- DPI, PAS, NIT
 Documento NVARCHAR(20) NOT NULL,
 Segmento NVARCHAR(20) NOT NULL, -- Retail, Premium, Pyme
 FechaAlta DATE NOT NULL,
 CONSTRAINT UQ_Cliente UNIQUE (TipoDocumento, Documento)
);

CREATE TABLE Cuenta (
 CuentaId INT IDENTITY PRIMARY KEY,
 ClienteId INT NOT NULL REFERENCES Cliente(ClienteId),
 Numero CHAR(16) NOT NULL UNIQUE,
 Moneda CHAR(3) NOT NULL, -- GTQ, USD
 Tipo NVARCHAR(12) NOT NULL, -- Monetaria, Ahorro
 Estado NVARCHAR(12) NOT NULL, -- Activa, Bloqueada, Cerrada
 Saldo DECIMAL(19,4) NOT NULL,
 RowVersion ROWVERSION, -- token de concurrencia
 FechaApertura DATE NOT NULL
);

CREATE TABLE Canal (
 CanalId INT IDENTITY PRIMARY KEY,
 Nombre NVARCHAR(20) NOT NULL -- Web, App, Ventanilla, ACH
);

CREATE TABLE Transferencia (
 TransferenciaId BIGINT IDENTITY PRIMARY KEY,
 IdempotencyKey CHAR(36) NOT NULL UNIQUE,
 CuentaOrigenId INT NULL REFERENCES Cuenta(CuentaId),
 CuentaDestinoId INT NULL REFERENCES Cuenta(CuentaId),
 CuentaDestinoExt CHAR(34) NULL, -- destino externo (ACH)
 Monto DECIMAL(19,4) NOT NULL,
 Moneda CHAR(3) NOT NULL,
 CanalId INT NOT NULL REFERENCES Canal(CanalId),
 Estado NVARCHAR(12) NOT NULL, -- Pendiente, Validando,
 -- Aplicada, Rechazada, Revertida
 ReferenciaCore NVARCHAR(40) NULL, -- folio devuelto por el core
 FechaSolicitud DATETIME2 NOT NULL,
 FechaAplicacion DATETIME2 NULL
);

CREATE TABLE Movimiento (
 MovimientoId BIGINT IDENTITY PRIMARY KEY,
 CuentaId INT NOT NULL REFERENCES Cuenta(CuentaId),
 TransferenciaId BIGINT NULL REFERENCES Transferencia(TransferenciaId),
 Tipo CHAR(1) NOT NULL, -- D (debito) / C (credito)
 Monto DECIMAL(19,4) NOT NULL,
 SaldoPosterior DECIMAL(19,4) NOT NULL, -- saldo tras el movimiento
 Fecha DATETIME2 NOT NULL
);

CREATE TABLE TipoCambio (
 Moneda CHAR(3) NOT NULL, Fecha DATE NOT NULL,
 Tasa DECIMAL(18,6) NOT NULL, -- conversion a GTQ
 CONSTRAINT PK_TipoCambio PRIMARY KEY (Moneda, Fecha)
);

CREATE TABLE Tarifa (
 TarifaId INT IDENTITY PRIMARY KEY,
 CanalId INT NOT NULL REFERENCES Canal(CanalId),
 MontoDesde DECIMAL(19,4) NOT NULL,
 MontoHasta DECIMAL(19,4) NOT NULL, -- tramo [Desde, Hasta]
 Comision DECIMAL(19,4) NOT NULL, -- cargo fijo del tramo
 Porcentaje DECIMAL(9,6) NOT NULL -- % adicional sobre el monto
);
