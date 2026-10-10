package com.moneyday.backend.service;

import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.StatDTO;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.mapper.StatMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public interface StatService {
    StatDTO getStats();
}
