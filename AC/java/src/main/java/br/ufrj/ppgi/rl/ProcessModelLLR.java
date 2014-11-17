package br.ufrj.ppgi.rl;

import java.io.Serializable;

import org.ejml.simple.SimpleMatrix;

import br.ufrj.ppgi.matlab.EJMLMatlabUtils;
import br.ufrj.ppgi.rl.fa.LLR;
import br.ufrj.ppgi.rl.fa.LLRQueryVO;

public class ProcessModelLLR implements Serializable
{
  private static final long serialVersionUID = -2618952695582747034L;

  protected LLR             llr;

  private Specification     specification;

  public void init(Specification specification)
  {
    this.specification = specification;

    llr = new LLR(specification.getProcessModelMemory(), specification.getObservationDimensions()
                                                         + specification.getActionDimensions(),
                  specification.getObservationDimensions(), specification.getProcessModelNeighbors());

  }

  public LLRQueryVO query(SimpleMatrix observation, SimpleMatrix action)
  {
    LLRQueryVO query = llr.query(createProcessoModelQuery(observation, action));
    query.setResult(EJMLMatlabUtils.wrap(query.getResult(), specification.getObservationMaxValue(),
                                         specification.getObservationMinValue()));

    return query;
  }

  public void add(SimpleMatrix observation, SimpleMatrix action, SimpleMatrix nextObservation)
  {
    SimpleMatrix input = createProcessoModelQuery(observation, action);

    llr.add(input, nextObservation);
  }

  public SimpleMatrix createProcessoModelQuery(SimpleMatrix observation, SimpleMatrix action)
  {
    SimpleMatrix input = new SimpleMatrix(1, specification.getObservationDimensions()
                                             + specification.getActionDimensions());

    input.setRow(0, 0, observation.getMatrix().data);
    input.setRow(0, specification.getObservationDimensions(), action.getMatrix().data);
    return input;
  }

  public LLR getLLR()
  {
    return llr;
  }
}
