import { Content } from './Content';
import { MODULES } from './modules';

export default {
  title: 'Content',
};

export const Usage = () => (
  <Content
    modules={MODULES.map((module) => ({
      ...module,
      functions: module.reference ? [] : ['RevertMem', 'ReAllocVec', 'AllocNewList', 'AllocNode'],
    }))}
  />
);
