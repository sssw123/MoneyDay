<template>
  <div style="padding: 24px;">
    <a-card title="账单周期模板">
      <div style="margin-bottom: 16px;">
        <a-button type="primary" @click="showModal">新增模板</a-button>
      </div>
      <a-table :dataSource="templates" :columns="columns" rowKey="id">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'startDay'">
            {{ record.startDay === 31 ? '月末' : record.startDay + '号' }}
          </template>
          <template v-else-if="column.key === 'isDefault'">
            <a-tag :color="record.isDefault === 1 ? 'green' : 'default'">
              {{ record.isDefault === 1 ? '当前默认' : '否' }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a v-if="record.isDefault !== 1" @click="setDefault(record.id)">设为默认</a>
              <a @click="editTemplate(record)">编辑</a>
              <a-popconfirm title="确定删除吗？" @confirm="deleteTemplate(record.id)">
                <a style="color: red">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <a-modal v-model:open="visible" :title="editingId ? '编辑模板' : '新增模板'" @ok="handleOk">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="模板名称" required>
          <a-input v-model:value="formState.name" placeholder="例如：发薪日周期" />
        </a-form-item>
        <a-form-item label="起算日" required help="每月从几号开始算作新的一月（输入 31 代表每月末）">
          <a-input-number v-model:value="formState.startDay" :min="1" :max="31" style="width: 100%" />
        </a-form-item>
        <a-form-item label="全局默认固存" help="所有新周期默认的必攒金额">
          <a-input-number v-model:value="formState.defaultFixedDeposit" :min="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="设为默认">
          <a-switch :checked="formState.isDefault === 1" @change="(val: boolean | string | number) => formState.isDefault = val ? 1 : 0" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const templates = ref([]);
const visible = ref(false);
const editingId = ref<number | null>(null);

const formState = ref({
  name: '',
  startDay: 1,
  defaultFixedDeposit: 0,
  isDefault: 0
});

const columns = [
  { title: '模板名称', dataIndex: 'name', key: 'name' },
  { title: '起算日', key: 'startDay' },
  { title: '全局默认固存', dataIndex: 'defaultFixedDeposit', key: 'defaultFixedDeposit' },
  { title: '是否默认', key: 'isDefault' },
  { title: '操作', key: 'action' }
];

const fetchTemplates = async () => {
  templates.value = await request.get('/cycle-templates');
};

const showModal = () => {
  editingId.value = null;
  formState.value = { name: '', startDay: 1, defaultFixedDeposit: 0, isDefault: 0 };
  visible.value = true;
};

const editTemplate = (record: any) => {
  editingId.value = record.id;
  formState.value = { ...record };
  visible.value = true;
};

const setDefault = async (id: number) => {
  try {
    await request.post(`/cycle-templates/${id}/default`);
    message.success('设置成功，首页看板已更新');
    fetchTemplates();
  } catch (e) {}
};

const handleOk = async () => {
  try {
    if (editingId.value) {
      await request.put(`/cycle-templates/${editingId.value}`, formState.value);
      message.success('更新成功');
    } else {
      await request.post('/cycle-templates', formState.value);
      message.success('添加成功');
    }
    visible.value = false;
    fetchTemplates();
  } catch (e) {}
};

const deleteTemplate = async (id: number) => {
  try {
    await request.delete(`/cycle-templates/${id}`);
    message.success('删除成功');
    fetchTemplates();
  } catch (e) {}
};

onMounted(() => {
  fetchTemplates();
});
</script>
