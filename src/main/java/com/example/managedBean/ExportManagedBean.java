package com.example.managedBean;

import com.example.model.entity.UsuarioPessoa;
import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.NamedEvent;
import javax.inject.Named;
import javax.servlet.http.HttpServletResponse;
import java.io.OutputStream;

@Named
@ViewScoped
public class ExportManagedBean {

        private String name;
        private String surname;
        private int age;
        private String city;

        public void postProcessXLS(Object document) {
            HSSFWorkbook wb = (HSSFWorkbook) document;
            HSSFSheet sheet = wb.getSheetAt(0);
            CellStyle style = wb.createCellStyle();
            style.setFillBackgroundColor(IndexedColors.AQUA.getIndex());

            for (Row row : sheet) {
                for (Cell cell : row) {
                    cell.setCellValue(cell.getStringCellValue().toUpperCase());
                    cell.setCellStyle(style);
                }
            }
        }
}