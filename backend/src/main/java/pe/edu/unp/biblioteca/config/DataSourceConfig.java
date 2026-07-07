package pe.edu.unp.biblioteca.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class DataSourceConfig {
    // La configuración del DataSource y JdbcTemplate es manejada automáticamente por 
    // Spring Boot AutoConfiguration gracias a spring-boot-starter-jdbc y application.properties.
    // Esta clase queda como estructura base en caso se requiera configuración programática extra.
}
