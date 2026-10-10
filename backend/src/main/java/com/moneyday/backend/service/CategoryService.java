package com.moneyday.backend.service;

import com.moneyday.backend.entity.Category;
import com.moneyday.backend.mapper.CategoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

public interface CategoryService {
    List<Category> getAllCategories();
    Category getCategoryById(Long id);
    Category addCategory(Category category);
    Category updateCategory(Category category);
    void deleteCategory(Long id);
}
