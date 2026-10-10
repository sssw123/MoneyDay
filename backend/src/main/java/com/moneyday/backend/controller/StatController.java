package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.StatDTO;
import com.moneyday.backend.service.StatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stats")
public class StatController {

    @Autowired
    private StatService statService;

    @GetMapping
    public Result<StatDTO> getStats() {
        return Result.success(statService.getStats());
    }
}
